class BeatsController < ApplicationController
	respond_to :json
	

	def beats_agent
		@beats_agent ||= BeatsWrapper.new(beats_user_id, beats_auth_token)
	end

	def mog_agent
		@mog_agent ||= MogWrapper.new(mogid)
	end

	def login
		@beats_agent = BeatsWrapper.new
		success = @beats_agent.login(params[:username], params[:password])

		if success
			render :json => {:user_id => @beats_agent.user_id, :auth_token => @beats_agent.auth_token}, :status => 200
		else
			render :nothing => true, :status => 401
		end
	end

	def create_playlists
		playlists = mog_agent.get_playlists
		playlists.each do |mog_playlist|
			beats_playlist = beats_agent.create_playlist(mog_playlist.name)

			mog_agent.get_playlist_tracks(mog_playlist).each do |track|
				beats_agent.search(track) if track.beats_id.nil?
				beats_agent.add_track_to_playlist(beats_playlist, track)
			end
		end
	end

	def favorite_tracks
		start_position = (params[:start_position] || 0).to_i
		# end_position = start_position + (params[:limit] || 10).to_i
		limit = (params[:limit] || 10).to_i
		tracks = mog_agent.get_favorite_tracks(start_position, limit)

		favorited_tracks = []
		missing_tracks = []
		error_tracks = []

		tracks.each do |track|
			begin
				beats_agent.search(track) if track.beats_id.nil?

				unless track.beats_id.nil?
					beats_agent.favorite(track)
					beats_agent.add_to_library(track)
					favorited_tracks << track
				else
					error_tracks << track
				end
			rescue
				error_tracks << track
			end
		end

		render :json => {:favorited_tracks => favorited_tracks, :error_tracks => error_tracks.collect{|x| {:title => "#{x.artist_name} - #{x.track_name}"}}}, :status => 201
	end

	def favorite_albums
		albums = mog_agent.get_favorite_albums[0..params[:limit].to_i]

		favorited_albums = []
		missing_albums = []
		error_albums = []

		albums.each do |album|
			begin
				beats_agent.search(album) if album.beats_id.nil?

				unless album.beats_id.nil?
					beats_agent.favorite(album)
					beats_agent.add_to_library(album)
					favorited_albums << album
				else
					error_albums << album
				end
			rescue
				error_albums << album
			end
		end

		render :json => {:favorited_albums => favorited_albums, :error_albums => error_albums.collect{|x| {:title => "#{x.artist_name} - #{x.album_name}"}}}, :status => 201
	end

	def favorite_artists
		artists = mog_agent.get_favorite_artists[0..params[:limit].to_i]

		favorited_artists = []
		missing_artists = []
		error_artists = []

		artists.each do |artist|
			begin
				beats_agent.search(artist) if artist.beats_id.nil?

				unless artist.beats_id.nil?
					beats_agent.follow(artist)
					favorited_artists << artist
				else
					error_artists << artist
				end
			rescue
				error_artists << artist
			end
		end

		render :json => {:favorited_artists => favorited_artists, :error_artists => error_artists.collect{|x| {:title => "#{x.artist_name}"}}}, :status => 201
	end
end