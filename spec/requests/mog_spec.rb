require 'spec_helper'
require 'support/auth_helper'

describe "MOG" do

  include AuthHelper

  describe "login" do
  	it "should log in the user to MOG" do
  		post "/mog/login", {:username => 'rsnorman15@gmail.com', :password => 'wambam15'}, auth_parameters

  		response.should be_ok
  		JSON.parse(response.body)['mogid'].should_not be_nil
  	end

  	it "should not log in the user to MOG with bad credentials" do
  		post "/mog/login", {:username => 'rsnorman15@gmail.com', :password => 'badpassword'}, auth_parameters

  		response.status.should eq 401
  	end
  end

  describe "GET /mog/playlists" do
  	it "should get all the playlists for a user" do
  		get "/mog/playlists", {:format => :json}, auth_parameters
  		response.should be_ok
  		playlists = JSON.parse(response.body)
  		playlists.size.should eq 34
  		playlists.first["name"].should eq "2009 Top 14 Songs"
		playlists.first["url"].should eq "https://mog.com/v2/playlists/3076381.json?ts=1395720541&api_token=V3.PpcEwuNWs6emXNGOz2GLsr27FdV3X3eiykcVmJtzBNZAQ-ArAydsPWN5p6-zcRFL&allow_nonstreamable_token=1"
  	end
  end

  describe "GET /mog/favorite_tracks" do
    it "should get all the favorite tracks for a user" do
      get "/mog/favorite_tracks", {:format => :json}, auth_parameters
      
      response.should be_ok
      favorites = JSON.parse(response.body)
      
      favorites.size.should be > 519
      favorites.first["artist_name"].should eq "Liars"
      favorites.first["album_name"].should eq "Mess"
      favorites.first["track_name"].should eq "Mess On A Mission"
      favorites.first["mog_id"].should eq "100562109"
    end
  end

  describe "GET /mog/favorite_albums" do
    it "should get all the favorite albums for a user" do
      get "/mog/favorite_albums", {:format => :json}, auth_parameters
      response.should be_ok
      
      favorites = JSON.parse(response.body)
      
      favorites.size.should be > 64
      favorites.first["artist_name"].should eq "Cloud Nothings"
      favorites.first["album_name"].should eq "Here And Nowhere Else"
      favorites.first["mog_id"].should eq "101040151"
    end
  end

  describe "GET /mog/favorite_artists" do
    it "should get all the favorite artist for a user" do
      get "/mog/favorite_artists", {:format => :json}, auth_parameters
      response.should be_ok
      
      favorites = JSON.parse(response.body)
      
      favorites.size.should be > 7
      favorites.first["artist_name"].should eq "Nine Inch Nails"
      favorites.first["mog_id"].should eq "24468"
    end
  end  

  describe "GET /mog/favorite_tracks/count" do
  	it "should get the count of favorite tracks for a user" do
  		get "/mog/favorite_tracks/count", {:format => :json}, auth_parameters
  		
  		response.should be_ok
  		response_count = JSON.parse(response.body)
  		
  		response_count['count'].should be > 519
  	end
  end

  describe "GET /mog/favorite_albums/count" do
    it "should get the count of favorite albums for a user" do
      get "/mog/favorite_albums/count", {:format => :json}, auth_parameters
      response.should be_ok
      
      response_count = JSON.parse(response.body)
      
      response_count['count'].should be > 64
    end
  end

  describe "GET /mog/favorite_artists/count" do
  	it "should get the count of favorite artists for a user" do
  		get "/mog/favorite_artists/count", {:format => :json}, auth_parameters
  		response.should be_ok
  		
  		response_count = JSON.parse(response.body)
  		
  		response_count['count'].should be > 7
  	end
  end
end