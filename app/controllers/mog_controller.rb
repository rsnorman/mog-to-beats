class MogController < ApplicationController
	respond_to :json
	before_filter :get_agent, :except => :login

	def get_agent
		@agent = MogWrapper.new(mogid)
	end

	def login
		@agent = MogWrapper.new
		success = @agent.login(params[:username], params[:password])

		if success
			render :json => {:mogid => @agent.mogid}, :status => 200
		else
			render :nothing => true, :status => 401
		end
	end

	def playlists
		respond_with @agent.get_playlists
	end

	def favorite_tracks
		respond_with @agent.get_favorite_tracks
	end

	def favorite_albums
		respond_with @agent.get_favorite_albums
	end

	def favorite_artists
		respond_with @agent.get_favorite_artists
	end

	def favorite_track_count
		render :json => {:count => @agent.get_favorite_track_count}
	end

	def favorite_album_count
		render :json => {:count => @agent.get_favorite_album_count}
	end

	def favorite_artist_count
		render :json => {:count => @agent.get_favorite_artist_count}
	end
end