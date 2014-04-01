require 'spec_helper'
require 'support/auth_helper'

describe "MOG" do

  include AuthHelper

  describe "login" do
  	it "should log in the user to MOG" do
  		post "/mog/login", {:username => 'rsnorman15@gmail.com', :password => 'wambam15'}, auth_parameters

  		response.should be_ok
  		JSON.parse(response.body)['success'].should be_true
  	end

  	it "should not log in the user to MOG with bad credentials" do
  		post "/mog/login", {:username => 'rsnorman15@gmail.com', :password => 'badpassword'}, auth_parameters

  		response.should be_ok
  		JSON.parse(response.body)['success'].should be_false
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
  	it "should get all the playlists for a user" do
  		get "/mog/favorite_tracks", {:format => :json}, auth_parameters
  		
  		response.should be_ok
  		favorites = JSON.parse(response.body)
  		
  		favorites.size.should eq 519
		favorites.first["artist_name"].should eq "Japandroids"
		favorites.first["album_name"].should eq "Post-Nothing"
		favorites.first["track_name"].should eq "Young Hearts Spark Fire"
		favorites.first["mog_id"].should eq "30596455"
  	end
  end

  describe "GET /mog/favorite_albums" do
  	it "should get all the playlists for a user" do
  		get "/mog/favorite_albums", {:format => :json}, auth_parameters
  		response.should be_ok
  		
  		favorites = JSON.parse(response.body)
  		
  		favorites.size.should eq 64
		favorites.first["artist_name"].should eq "Perfect Pussy"
		favorites.first["album_name"].should eq "I"
		favorites.first["mog_id"].should eq "99584969"
  	end
  end
end