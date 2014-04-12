require 'rubygems'
require 'mechanize'
require 'rest-client'

class BeatsWrapper

	BEATS_URL = "http://www.beatsmusic.com/"
	BEATS_TEST_AUTH_TOKEN = "Mg%3D%3D%246%2FJhhYwCEf%2BhGKR7GGiiDe1%2BFLGQI%2BwIiT6ZwZBdIEkj398CFPnrx09AAOfs1jw6CSFaQFljRNIt9xcom%2B%2FXwg1PUi%2FuWrFEQiMmIyvcmwL4v%2BoFmE%2FV5YqINtY6xpC9Ch%2F72IIgOcSF1iO1qMRMcg%3D%3D"
	BEATS_TEST_USER_ID = "139591750279758080"

	attr_accessor :agent
	attr_reader :is_logged_in
	attr_reader :auth_token
	attr_reader :user_id

	def initialize(user_id = nil, auth_token = nil)
		if auth_token
			# agent.cookie_jar.load(Rails.root.join("cookie_jars","#{username}-beats.cookies"))
			@user_id = user_id
			@auth_token = auth_token
			set_authorization_headers
			@is_logged_in = true
		end
	end

	def agent
		@agent ||= Mechanize.new { |agent|
		  agent.user_agent_alias = 'Mac Safari'
		  agent.ssl_version, agent.verify_mode = 'SSLv3', OpenSSL::SSL::VERIFY_NONE
		}
	end

	def login(username, password)

		self.agent.get(BEATS_URL) do |page|

			login_page = page.link_with(:href => "https://account.beatsmusic.com/login").click

			home_page = login_page.form_with(:action => "/login") do |login_form|
				login_form.field_with(:name => "login").value = username
				login_form.field_with(:name => "password").value = password
			end.submit
		end

		# Returns true if successfully logged in
		if self.agent.page.uri.to_s == "https://listen.beatsmusic.com/"
			@auth_token = self.agent.cookies.detect{|x| x.name == "access_token"}.value rescue nil
			@user_id = self.agent.cookies.detect{|x| x.name == "user_id"}.value rescue nil
			set_authorization_headers
			# self.agent.cookie_jar.save(Rails.root.join("cookie_jars","#{username}-beats.cookies"), :session => true)
			@is_logged_in = !@auth_token.nil? && !@user_id.nil?
		else
			false
		end
	end

	def search(item)
		query = item.artist_name.downcase.gsub('!', '')
		if item.is_a?(Track)
			track_name = item.track_name.downcase.gsub(/(\([\s\S]*\))/, '').gsub('&', 'and')
			query = "#{query} #{track_name}"

			item = match(query, item.artist_name, item.track_name, item)

			if item.beats_id.nil? && item.artist_name.downcase.include?('and')
				query = "#{item.artist_name.split(/and/i).first} #{track_name}"
				query = CGI.escape(query)

				item = match(query, item.artist_name, item.track_name, item)
			end

			if item.beats_id.nil?
				query = "#{track_name}"
				query = CGI.escape(query)

				item = match(query, item.artist_name, track_name, item)
			end


		elsif item.is_a?(Album)
			url = "https://api.beatsmusic.com/api/search?q="
			query = "#{query} #{item.album_name}".gsub(' ', '+')
			response = RestClient.get("#{url}#{query}&type=album", get_authorization_headers)
			album = JSON.parse(response.body)["data"].first
			
			if (album["detail"].include?(item.artist_name) || item.artist_name.include?(album["detail"])) && (album["display"].include?(item.album_name) || item.album_name.include?(album["display"]))
				item.beats_id = album["id"]
				item.save
			end

		elsif item.is_a?(Artist)
			url = "https://api.beatsmusic.com/api/search?q="
			query = "#{query} #{item.artist_name}".gsub(' ', '+')
			response = RestClient.get("#{url}#{query}&type=artist", get_authorization_headers)
			artist = JSON.parse(response.body)["data"].first
			
			if (artist["detail"].include?(item.artist_name) || item.artist_name.include?(artist["detail"])) && (artist["display"].include?(item.artist_name) || item.artist_name.include?(artist["display"]))
				item.beats_id = artist["id"]
				item.save
			end
		end
			
		item
	end

	def match(query, artist_name, track_name, item)
		url = "https://api.beatsmusic.com/api/search?q="
		artist_name = artist_name.downcase
		track_name = track_name.downcase
		query = CGI.escape(query)
		response = RestClient.get("#{url}#{query}&type=track", get_authorization_headers)
		
		tracks = JSON.parse(response.body)["data"]

		tracks.each do |track|
			if (track && track["detail"].downcase.include?(artist_name) || artist_name.include?(track["detail"].downcase)) && (track["display"].downcase.gsub('&', 'and').include?(track_name) || track_name.include?(track["display"].downcase.gsub('&', 'and')))
				item.beats_id = track["id"]
				item.save
				break
			end
		end

		item
	end

	def favorite(item)
		url = "https://api.beatsmusic.com/api/users/#{user_id}/ratings/#{item.beats_id}"
		params = {
			:id => 	item.beats_id,
			:rated => { :display => "", :id => item.beats_id, :ref_type => item.class.to_s.downcase },
			:rating => 1,
			:type => "rating",
			:updated_at => Time.now.to_i,
			:user_id => user_id
		}

		response = RestClient.put(url, params, get_authorization_headers)
	end

	def add_to_library(item)
		url = "https://api.beatsmusic.com/api/users/#{user_id}/mymusic/#{item.beats_id}"
		params = {
			:id => 	item.beats_id,
		}

		response = RestClient.put(url, params, get_authorization_headers)
	end

	def remove_from_library(item)
		url = "https://api.beatsmusic.com/api/users/#{user_id}/mymusic/#{item.beats_id}"
		
		response = RestClient.delete(url, get_authorization_headers)
	rescue
		nil
	end

	def is_in_library?(item)
		url = "https://api.beatsmusic.com/api/users/#{user_id}/mymusic/#{item.class.to_s.downcase.pluralize}?limit=200"
		response = RestClient.get(url, get_authorization_headers)
	
		!JSON.parse(response.body)["data"].detect{|x| x["id"] == item.beats_id}.nil?
	rescue Exception => e
		false
	end

	def follow(artist)
		url = "https://api.beatsmusic.com/api/users/#{user_id}/follows/#{artist.beats_id}"
		params = {
			:id => 	artist.beats_id,
		}
		response = RestClient.put(url, params, get_authorization_headers)
	end

	def unfollow(artist)
		url = "https://api.beatsmusic.com/api/users/#{user_id}/follows/#{artist.beats_id}"
		response = RestClient.delete(url, get_authorization_headers)
	end

	def is_followed?(artist)
		url = "https://api.beatsmusic.com/api/users/#{user_id}/follows/#{artist.beats_id}"
		response = RestClient.get(url, get_authorization_headers)

		JSON.parse(response.body)["data"]["object"]["id"] == artist.beats_id
	rescue Exception => e
		false
	end

	def unfavorite(item)
		url = "https://api.beatsmusic.com/api/users/#{user_id}/ratings/#{item.beats_id}"

		response = RestClient.delete(url, get_authorization_headers)
	rescue
		nil
	end

	def is_favorited?(item)
		url = "https://api.beatsmusic.com/api/users/#{user_id}/ratings/#{item.beats_id}"
		response = RestClient.get(url, get_authorization_headers)
	
		true
	rescue Exception => e
		false
	end

	def favorite_album(album)
		url = "https://api.beatsmusic.com/api/users/#{user_id}/ratings/#{album.beats_id}"

		params = {
			:id => 	album.beats_id,
			:rated => { :display => "", :id => album.beats_id, :ref_type => "album" },
			:rating => 1,
			:type => "rating",
			:updated_at => Time.now.to_i,
			:user_id => user_id
		}

		response = RestClient.put(url, params, get_authorization_headers)

		JSON.parse(response)["data"]["code"] == "OK"
	end

	def favorite_artist(artist)
		url = "https://api.beatsmusic.com/api/users/#{user_id}/ratings/#{artist.beats_id}"

		params = {
			:id => 	artist.beats_id,
			:rated => { :display => "", :id => artist.beats_id, :ref_type => "artist" },
			:rating => 1,
			:type => "rating",
			:updated_at => Time.now.to_i,
			:user_id => user_id
		}

		response = RestClient.put(url, params, get_authorization_headers)

		JSON.parse(response)["data"]["code"] == "OK"
	end

	def create_playlist(name)
		url = "https://api.beatsmusic.com/api/playlists"
		params = {
			:name => 	name,
			:created_at => Time.now.to_i,
			:updated_at => Time.now.to_i,
			:user_id => user_id
		}

		response = RestClient.post(url, params, get_authorization_headers)

		JSON.parse(response)
	end

	def delete_playlist(id)
		url = "https://api.beatsmusic.com/api/playlists/#{id}"
		response = RestClient.delete(url, get_authorization_headers)
	end

	def add_track_to_playlist(playlist, tracks)
		url = "https://api.beatsmusic.com/api/playlists/#{playlist.beats_id}/tracks"
		params = {
			:track_ids => 	tracks.is_a?(Array) ? tracks.collect{|x| x.beats_id} : [tracks.beats_id]
		}

		response = RestClient.post(url, params, get_authorization_headers)
		JSON.parse(response)["code"] == "OK"
	end
	
	private

	def get_authorization_headers
		{
			'Authorization' => "Bearer #{URI.unescape(@auth_token)}",
			"Accept" =>	"application/json, text/javascript, */*; q=0.01",
			"Accept-Encoding" =>	"gzip, deflate",
			"Accept-Language" =>	"en-US,en;q=0.5",
			"Host" =>	"api.beatsmusic.com",
			"Origin" =>	"https://listen.beatsmusic.com",
			"Referer" =>	"https://listen.beatsmusic.com/",
			"User-Agent" =>	"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:27.0) Gecko/20100101 Firefox/27.0"
		}
	rescue
		raise "Auth Token not found"
	end

	def set_authorization_headers
		self.agent.request_headers = get_authorization_headers
	end
end