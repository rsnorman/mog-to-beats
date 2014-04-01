require 'spec_helper'

describe MogWrapper do
	before :all do
		@client = MogWrapper.new
		@client.login('rsnorman15@gmail.com', 'wambam15')
	end

	describe "initialize" do
		it "should create an agent with cookies loaded if cookie jar path is provided" do
			client = MogWrapper.new('rsnorman15@gmail.com')
			client.is_logged_in.should be_true
			client.get_playlists.size.should eq 34
		end
	end

	describe "login" do
		# it "should login in a user" do
		# 	@client.login('rsnorman15@gmail.com', 'wambam15').should be_true
		# end

		# it "should not login in a user with incorrect credentials" do
		# 	@client.login('rsnorman15@gmail.com', 'badpassword').should be_false
		# end

		# it "should save the cookie jar in a file with the email address as the name of the file" do
		# 	@client.login('rsnorman15@gmail.com', 'wambam15')
		# 	File.exists?(Rails.root.join('cookie_jars', 'rsnorman15@gmail.com-mog.cookies')).should be_true
		# end
	end

	describe "get_playlists" do
		it "should return a list of playlists" do
			playlists = @client.get_playlists

			playlists.size.should eq 34
		end

		it "should return a name and url for each playlist" do
			playlists = @client.get_playlists

			playlists.first.name.should eq "2009 Top 14 Songs"
			playlists.first.url.should eq "https://mog.com/v2/playlists/3076381.json?ts=1395720541&api_token=V3.PpcEwuNWs6emXNGOz2GLsr27FdV3X3eiykcVmJtzBNZAQ-ArAydsPWN5p6-zcRFL&allow_nonstreamable_token=1"
		end

		it "should return a playlist with all the songs" do
			playlist = @client.get_playlists.first
			playlist.tracks = @client.get_playlist_tracks(playlist)
			playlist.tracks.size.should eq 12
			playlist.tracks.first.artist_name.should eq "Japandroids"
			playlist.tracks.first.album_name.should eq "Post-Nothing"
			playlist.tracks.first.track_name.should eq "Young Hearts Spark Fire"
			playlist.tracks.first.mog_id.should eq "30596455"
		end
	end

	describe "get_favorite_tracks" do
		it "should return a list of favorite tracks" do
			favorites = @client.get_favorite_tracks

			favorites.size.should eq 519
			favorites.first.artist_name.should eq "Japandroids"
			favorites.first.album_name.should eq "Post-Nothing"
			favorites.first.track_name.should eq "Young Hearts Spark Fire"
			favorites.first.mog_id.should eq "30596455"

		end
	end

	describe "get_favorite_albums" do
		it "should return a list of favorites" do
			favorites = @client.get_favorite_albums

			favorites.size.should eq 64
			favorites.first.artist_name.should eq "Perfect Pussy"
			favorites.first.album_name.should eq "I"
			favorites.first.mog_id.should eq "99584969"

		end
	end
end