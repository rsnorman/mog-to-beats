class MogController < ApplicationController
	respond_to :json
	before_filter :get_agent, :except => :login

	def get_agent
		@agent = MogWrapper.new(mog_username)
	end

	def login
		@agent = MogWrapper.new
		success = @agent.login(params[:username], params[:password])

		render :json => {:success => success}, :status => 200
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
end