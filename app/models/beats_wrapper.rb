require 'rubygems'
require 'mechanize'
require 'rest-client'

class BeatsWrapper

	BEATS_URL = "http://www.beatsmusic.com/"

	attr_accessor :agent
	attr_reader :is_logged_in

	def initialize(username = nil)
		if username
			agent.cookie_jar.load(Rails.root.join("cookie_jars","#{username}-beats.cookies"))
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
			set_authorization_headers
			self.agent.cookie_jar.save(Rails.root.join("cookie_jars","#{username}-beats.cookies"), :session => true)
			@is_logged_in = true
			true
		else
			false
		end
	end

	def search(item)
		url = "https://api.beatsmusic.com/api/search/federated?q="
		query = item.artist_name
		if item.is_a?(Track)
			query = "#{query} #{item.track_name}".gsub(' ', '+')
			response = RestClient.get("#{url}#{query}", get_authorization_headers)
			track = JSON.parse(response.body)["data"]["tracks"].first
			
			if (track["detail"].include?(item.artist_name) || item.artist_name.include?(track["detail"])) && (track["display"].include?(item.track_name) || item.track_name.include?(track["display"]))
				item.beats_id = track["id"]
				item.save
			end
		elsif item.is_a?(Album)
			query = "#{query} #{item.album_name}".gsub(' ', '+')
			response = RestClient.get("#{url}#{query}", get_authorization_headers)
			album = JSON.parse(response.body)["data"]["albums"].first
			
			if (album["detail"].include?(item.artist_name) || item.artist_name.include?(album["detail"])) && (album["display"].include?(item.album_name) || item.album_name.include?(album["display"]))
				item.beats_id = album["id"]
				item.save
			end
		end
			
		item
	end

	def favorite(item)
		url = "https://api.beatsmusic.com/api/users/#{user_id}/ratings/#{item.beats_id}"
		params = {
			:id => 	item.beats_id,
			:rated => { :display => "", :id => item.beats_id, :ref_type => item.is_a?(Track) ? "track" : "album" },
			:rating => 1,
			:type => "rating",
			:updated_at => Time.now.to_i,
			:user_id => user_id
		}

		response = RestClient.put(url, params, get_authorization_headers)
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

	# def put(uri, query = {}, headers = {})
	# 	node = {}
	# 	# Create a fake form
	# 	class << node
	# 		def search(*args); []; end
	# 	end
	# 	node['method'] = 'PUT'
	# 	node['enctype'] = 'application/x-www-form-urlencoded'

	# 	form = Mechanize::Form.new(node)

	# 	query.each { |k, v|
	# 	  form.fields << Mechanize::Form::Field.new({'name' => k.to_s},v)
	# 	}

	# 	self.agent.send(:post_form, uri, form, headers)
	# end

	def user_id
		self.agent.cookies.detect{|x| x.name == "user_id"}.value
	rescue
		raise "User ID not found"
	end

	def get_authorization_headers
		auth_token = self.agent.cookies.detect{|x| x.name == "access_token"}.value
		{
			'Authorization' => "Bearer #{URI.unescape(auth_token)}",
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