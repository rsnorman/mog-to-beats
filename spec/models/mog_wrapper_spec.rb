require 'spec_helper'

describe MogWrapper do
	before :all do
		@client = MogWrapper.new("V3.PpcEwuNWs6emXNGOz2GLsr27FdV3X3eiykcVmJtzBNZAQ-ArAydsPWN5p6-zcRFL")
		# @client.login('rsnorman15@gmail.com', 'wambam15')
	end

	describe "initialize" do
		it "should create an agent with cookies loaded if cookie jar path is provided" do
			@client.is_logged_in.should be_true
			@client.get_playlists.size.should eq 34
		end
	end

	describe "login" do
		it "should login in a user" do
			client = MogWrapper.new
			client.login('rsnorman15@gmail.com', 'wambam15').should be_true
		end

		it "should not login in a user with incorrect credentials" do
			client = MogWrapper.new
			client.login('rsnorman15@gmail.com', 'badpassword').should be_false
		end
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

			favorites.size.should be > 519
			favorites.first.artist_name.should eq "Liars"
			favorites.first.album_name.should eq "Mess"
			favorites.first.track_name.should eq "Mess On A Mission"
			favorites.first.mog_id.should eq "100562109"

		end
	end

	describe "get_favorite_albums" do
		it "should return a list of favorites" do
			favorites = @client.get_favorite_albums

			favorites.size.should be > 64
			favorites.first.artist_name.should eq "Cloud Nothings"
			favorites.first.album_name.should eq "Here And Nowhere Else"
			favorites.first.mog_id.should eq "101040151"
		end
	end

	describe "get_favorite_artists" do
		it "should return a list of favorites" do
			favorites = @client.get_favorite_artists

			favorites.size.should be > 7
			favorites.first.artist_name.should eq "Nine Inch Nails"
			favorites.first.mog_id.should eq "24468"
		end
	end

	describe "get_favorite_track_count" do
		it "should return a count of favorite tracks" do
			count = @client.get_favorite_track_count

			count.should be > 519

		end
	end

	describe "get_favorite_album_count" do
		it "should return a count of favorite albums" do
			count = @client.get_favorite_album_count

			count.should be > 64
		end
	end

	describe "get_favorite_artist_count" do
		it "should return a count of favorite artists" do
			count = @client.get_favorite_artist_count

			count.should be > 7
		end
	end
end