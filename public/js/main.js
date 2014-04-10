(function($) {
	var mogUsername, beatsUsername, favoriteSongCount, favoriteAlbumCount;
	var $beginWrapper, $mogWrapper, $beatsWrapper, $transferWrapper;

	function getFavoriteSongCount(success) {
		$.ajax({
			url: "/mog/favorite_tracks/count",
			headers: {
				MOG_USER_NAME: mogUsername
			},
			success: function(songCount) {
				success && success(songCount.count);
			}
		});
	}

	function getFavoriteAlbumCount(success) {
		$.ajax({
			url: "/mog/favorite_albums/count",
			headers: {
				MOG_USER_NAME: mogUsername
			},
			success: function(albumCount) {
				success && success(albumCount.count);
			}
		});
	}

	function slideUp($panel) {
		$panel.css({
			top: $(window).height() + 50,
			display: 'block'
		});

		setTimeout(function() {
			$panel.css({
				top: 45
			});
		}, 100);
	}

	function login($form, success, error) {
		$form.submit(function() {
			var $button;
			$button = $form.find('.button');
			$button.parent().addClass('loading');
			$button.val('');

			$form.find('.error,.login-error').slideUp();

			$.ajax({
				method: 'POST',
				dataType: 'json',
				url: $form.attr('action'),
				data: {
					username: $form.find('[type="email"]').val(),
					password: $form.find('[type="password"]').val()
				},
				success: function(data) {

					$button.parent().removeClass('loading');

					success && success(data);
				},
				error: function(errorResponse) {
					if (errorResponse.status === 401) {
						$button.parent().removeClass('loading');
						$button.val('Login');
						$form.find('.login-error').slideDown();
					} else {
						$button.parent().removeClass('loading');
						$button.val('Login');
						$form.find('.error').slideDown();
					}

					error && error(error);
				}
			})

			return false;
		});
	}

	var currentPage, limit, totalSuccessCount, totalErrorCount;
	limit = 10;
	currentPosition = 0;
	totalSuccessCount = 0;
	totalErrorCount = 0;

	function transferSongs(success) {
		$errorTrackContainer = $('.error-track-container');
		$transferWrapper.find('.transferring-music').show();
		$transferWrapper.find('.loading-songs .loaded-music').hide();
		$transferWrapper.find('.loading-songs .button').css({
			opacity: 0
		});

		$.ajax({
			url: '/beats/favorite_tracks',
			method: 'POST',
			data: {
				limit: limit,
				start_position: currentPosition
			},
			headers: {
				MOG_USER_NAME: $mogWrapper.find('[type="email"]').val(),
				BEATS_USER_NAME: $beatsWrapper.find('[type="email"]').val()
			},
			success: function(data) {
				totalSuccessCount += data['favorited_tracks'].length
				$('.song-success-count').text(totalSuccessCount);
				totalErrorCount += data['error_tracks'].length;

				if (totalErrorCount > 0) {
					$('.error-tracks').slideDown();
					$('.song-error-count').text(totalErrorCount);
					for (var i = 0; i < data['error_tracks'].length; i++) {
						$errorTrackContainer.append($('<li></li>').text([data['error_tracks'][i].artist_name, ' - ',
							data['error_tracks'][i].track_name
						].join('')).hide().slideDown());
					}
				}

				if (currentPosition + limit <= favoriteSongCount) {
					currentPosition = currentPosition + limit;

					setTimeout(function() {
						transferSongs();
					}, 1000);
				} else {
					$('.transferring-music .button-loader').slideUp();
				}
			}
		});
	}

	$(document).ready(function() {

		$beginWrapper = $('#header-wrapper');
		$mogWrapper = $('#mog-login-wrapper');
		$beatsWrapper = $('#beats-login-wrapper');
		$transferWrapper = $('#transfer-wrapper');

		$('#begin-button').click(function() {
			slideUp($mogWrapper);
		});

		login($('#mog_login'), function() {
			slideUp($beatsWrapper);
		});

		login($('#beats_login'), function() {
			slideUp($transferWrapper);
			getFavoriteSongCount(function(songCount) {
				favoriteSongCount = songCount;
				$transferWrapper.find('.loading-songs .loading-music').slideUp();
				$transferWrapper.find('.loading-songs .loaded-music').slideDown(400, function() {
					$transferWrapper.find('.loading-songs .button').css({
						opacity: 1
					});
				})

				$transferWrapper.find('.song-count').text(favoriteSongCount);
			});
			getFavoriteAlbumCount(function(albumCount) {
				favoriteAlbumCount = albumCount;
				$transferWrapper.find('.loading-albums .loading-music').slideUp();
				$transferWrapper.find('.loading-albums .loaded-music').slideDown(400, function() {
					$transferWrapper.find('.loading-albums .button').css({
						opacity: 1
					});
				})


				$transferWrapper.find('.album-count').text(albumCount);
			});
		});


		$('#transfer_songs').click(transferSongs);

		$('.view-error-songs').click(function() {
			$('.error-track-container').slideDown();
		})

	});
})(jQuery);