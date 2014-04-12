(function($) {
	var mogUsername, beatsUsername, favoriteCount;
	var $beginWrapper, $mogWrapper, $beatsWrapper, $transferWrapper;
	var mogId, beatsUserId, beatsAuthToken;

	favoriteCount = {};

	function getFavoriteCount(type, success) {
		$.ajax({
			url: "/mog/favorite_" + type + "s/count",
			headers: {
				MOG_ID: mogId || "V3.PpcEwuNWs6emXNGOz2GLsr27FdV3X3eiykcVmJtzBNZAQ-ArAydsPWN5p6-zcRFL"
			},
			success: function(response) {
				success && success(response.count);
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
					console.log(data);
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

	var currentMusicType, currentMusicLabel, currentPage, limit, totalSuccessCount, totalErrorCount;
	limit = 10;
	currentPage = 0;
	currentPosition = 0;
	totalSuccessCount = 0;
	totalErrorCount = 0;

	function transferMusic(success) {
		$errorTrackContainer = $('.error-music-container');
		$transferWrapper.find('.transferring-music').show();
		$transferWrapper.find('.loading-music-container .loaded-music').hide();
		$('#begin-music-transfer').css({
			opacity: 0
		});
		$('#transfer-more').css({
			opacity: 0
		});

		$.ajax({
			url: '/beats/favorite_' + currentMusicType + 's',
			method: 'POST',
			data: {
				limit: limit,
				start_position: currentPosition
			},
			headers: {
				MOG_ID: mogId || "V3.PpcEwuNWs6emXNGOz2GLsr27FdV3X3eiykcVmJtzBNZAQ-ArAydsPWN5p6-zcRFL",
				BEATS_USER_ID: beatsUserId || "139591750279758080",
				BEATS_AUTH_TOKEN: beatsAuthToken || "Mg%3D%3D%246%2FJhhYwCEf%2BhGKR7GGiiDe1%2BFLGQI%2BwIiT6ZwZBdIEkj398CFPnrx09AAOfs1jw6CSFaQFljRNIt9xcom%2B%2FXwg1PUi%2FuWrFEQiMmIyvcmwL4v%2BoFmE%2FV5YqINtY6xpC9Ch%2F72IIgOcSF1iO1qMRMcg%3D%3D"
			},
			success: function(data) {
				totalSuccessCount += data['favorited_' + currentMusicType + 's'].length
				$('.music-success-count').text(totalSuccessCount);
				totalErrorCount += data['error_' + currentMusicType + 's'].length;

				if (totalErrorCount > 0) {
					$('.error-tracks').slideDown();
					$('.music-error-count').text(totalErrorCount);
					for (var i = 0; i < data['error_' + currentMusicType + 's'].length; i++) {
						$errorTrackContainer.append($('<li></li>').text(data['error_' + currentMusicType + 's'][i].title).hide().slideDown());
					}
				}

				if (currentPosition + limit <= favoriteCount[currentMusicType]) {
					currentPosition = currentPosition + limit;

					setTimeout(function() {
						transferMusic();
					}, 1000);
				} else {
					$('.transferring-music .button-loader').slideUp();
					$('#begin-music-transfer').hide();
					$('#transfer-more').show().css({
						opacity: 1
					});
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

		login($('#mog_login'), function(data) {
			mogId = data.mogid;
			slideUp($beatsWrapper);
		});

		login($('#beats_login'), function(data) {
			beatsUserId = data.user_id
			beatsAuthToken = data.auth_token
			slideUp($transferWrapper);
		});


		$('#begin-music-transfer').click(transferMusic);

		$('#transfer-more').click(function() {
			$('#transfer-progress').fadeOut(500, function() {
				$('#select-music-type').fadeIn();
				$('#transfer-more').hide();
			});
		});

		$('.view-error-music').click(function() {
			$('.error-track-container').slideDown();
		});

		function showTransferDiv(type, title) {

			currentMusicType = type;
			currentMusicLabel = title;
			currentPage = 0;
			currentPosition = 0;
			totalSuccessCount = 0;
			totalErrorCount = 0;

			$('#select-music-type').fadeOut(500, function() {
				$('#transfer-progress').fadeIn();
			});

			$('#transfer-progress .music-type').text(title);

			$('.transferring-music').hide();
			$('.error-music').hide();
			$('#begin-music-transfer').css({
				opacity: 0
			}).show();
			$('#transfer-more').css({
				opacity: 0
			}).show();
			$('.music-success-count').text(0);
			$('.music-error-count').text(0);
			$('.transferring-music .button-loader').show();
			$transferWrapper.find('.loading-music-container .loaded-music').hide();

			$transferWrapper.find('.loading-music-container .loading-music').show();

			getFavoriteCount(type, function(count) {
				favoriteCount[type] = count;
				$transferWrapper.find('.loading-music-container .loading-music').slideUp();
				$transferWrapper.find('.loading-music-container .loaded-music').slideDown(400, function() {
					$('#begin-music-transfer').css({
						opacity: 1
					});

					$('#transfer-more').css({
						opacity: 1
					});
				});

				$transferWrapper.find('.music-count').text(favoriteCount[type]);
			});
		}

		$('.transfer-choose').click(function() {
			showTransferDiv($(this).data().musicType, $(this).data().title);
		});

	});
})(jQuery);