require 'rubygems'
require 'mechanize'

class MogWrapper

	MOG_URL = "https://mog.com/"

	attr_writer :agent
	attr_reader :is_logged_in

	def agent
		@agent ||= Mechanize.new { |agent|
		  agent.user_agent_alias = 'Mac Safari'
		  agent.ssl_version, agent.verify_mode = 'SSLv3', OpenSSL::SSL::VERIFY_NONE
		}
	end

	def initialize(username = nil)
		if username
			agent.cookie_jar.load(Rails.root.join("cookie_jars","#{username}-mog.cookies"))
			@is_logged_in = true
		end
	end

	def login(username, password)

		self.agent.get(MOG_URL) do |page|
			
			login_page = page.link_with(:href => "/hp/sign_in").click

			home_page = login_page.form_with(:action => "/subscription_registrations/sign_in") do |login_form|
				login_form.field_with(:name => "user[login]").value = username
				login_form.field_with(:name => "user[password]").value = password
			end.submit
		end

		self.agent.cookie_jar.save(Rails.root.join("cookie_jars","#{username}-mog.cookies"), :session => true)

		# Returns true if successfully logged in
		@is_logged_in = self.agent.page.uri.to_s == "https://mog.com/m"
	end

	def get_playlists
		response = self.agent.get("https://mog.com/v2/playlists/user.json?ts=1395719796&api_token=V3.PpcEwuNWs6emXNGOz2GLsr27FdV3X3eiykcVmJtzBNZAQ-ArAydsPWN5p6-zcRFL&allow_nonstreamable_token=1")
			
		playlists = []

		JSON.parse(response.body)["playlists"].each do |playlist|
			url = "https://mog.com/v2/playlists/#{playlist["playlist_id"]}.json?ts=1395720541&api_token=V3.PpcEwuNWs6emXNGOz2GLsr27FdV3X3eiykcVmJtzBNZAQ-ArAydsPWN5p6-zcRFL&allow_nonstreamable_token=1"
			playlists << Playlist.new(playlist["name"], url)
		end

		playlists
	end

	def get_playlist_tracks(playlist)
		response = self.agent.get(playlist.url)
		tracks = JSON.parse(response.body)["tracks"].collect do |t|

			track = Track.find_by_mog_id(t["track_id"])

			if track.nil?
				track = Track.create(:album_name => t["album_name"], 
						  :track_name => t["track_name"],
						  :artist_name => t["artist_name"],
						  :mog_id => t["track_id"])
			end

			track
		end
	end

	def get_favorite_tracks(start_position = nil, limit = nil)
		tracks = []
		if start_position.nil?
			page = get_favorite_track_page

			while tracks.size < page["total"]
				tracks = tracks.concat(page["tracks"])
				page = get_favorite_track_page(page["count"] + page["index"])
			end

			tracks = create_tracks(tracks)
		else
			page = get_favorite_track_page(start_position, limit)
			tracks = create_tracks(page["tracks"])
		end
		
		tracks
	end

	def create_tracks(json_tracks)
		tracks = json_tracks.collect do |t|

			track = Track.find_by_mog_id(t["track_id"])

			if track.nil?
				track = Track.new(:album_name => t["album_name"], 
						  :track_name => t["track_name"],
						  :artist_name => t["artist_name"],
						  :mog_id => t["track_id"])
				track.save
			end

			track
		end

		tracks
	end

	def get_favorite_track_count
		get_favorite_track_page["total"]
	end

	def get_favorite_albums
		page = get_favorite_album_page
		albums = []

		while albums.size < page["total"]
			albums = albums.concat(page["albums"])
			page = get_favorite_album_page(page["count"] + page["index"])
		end

		albums = albums.collect do |t|

			album = Album.find_by_mog_id(t["album_id"])

			if album.nil?
				album = Album.new(
						  :album_name => t["album_name"],
						  :artist_name => t["artist_name"],
						  :mog_id => t["album_id"])
				album.save
			end

			album
		end
		
		albums
	end

	def get_favorite_album_count
		get_favorite_album_page["total"]
	end

	private

	def get_favorite_track_page(index = 0, size = 100)
		response = self.agent.get("https://mog.com/v2/bookmarks/tracks.json?explicit=1&index=#{index}&count=#{size}&ts=1395794345&api_token=V3.PpcEwuNWs6emXNGOz2GLsr27FdV3X3eiykcVmJtzBNZAQ-ArAydsPWN5p6-zcRFL&allow_nonstreamable_token=1")
		JSON.parse(response.body)
	end

	def get_favorite_album_page(index = 0, size = 100)
		response = self.agent.get("https://mog.com/v2/bookmarks/albums.json?explicit=1&index=#{index}&count=#{size}&ts=1395794345&api_token=V3.PpcEwuNWs6emXNGOz2GLsr27FdV3X3eiykcVmJtzBNZAQ-ArAydsPWN5p6-zcRFL&allow_nonstreamable_token=1")
		JSON.parse(response.body)
	end
	
end