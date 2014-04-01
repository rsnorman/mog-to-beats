class BeatsController < ApplicationController
	respond_to :json
	

	def beats_agent
		@beats_agent ||= BeatsWrapper.new(beats_username)
	end

	def mog_agent
		@mog_agent ||= MogWrapper.new(mog_username)
	end

	def login
		@beats_agent = BeatsWrapper.new
		success = @beats_agent.login(params[:username], params[:password])

		render :json => {:success => success}, :status => 200
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
		end_position = start_position + (params[:limit] || 10).to_i
		tracks = mog_agent.get_favorite_tracks[start_position..end_position]

		favorited_tracks = []
		missing_tracks = []
		error_tracks = []

		tracks.each do |track|
			begin
				beats_agent.search(track) if track.beats_id.nil?

				unless track.beats_id.nil?
					beats_agent.favorite(track)
					favorited_tracks << track
				else
					missing_tracks << track
				end
			rescue
				error_tracks << track
			end
		end

		render :json => {:favorited_tracks => favorited_tracks, :missing_tracks => missing_tracks, :error_tracks => error_tracks}, :status => 201
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
					favorited_albums << album
				else
					missing_albums << album
				end
			rescue
				error_albums << album
			end
		end

		render :json => {:favorited_albums => favorited_albums, :missing_albums => missing_albums, :error_albums => error_albums}, :status => 201
	end
end