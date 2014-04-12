require 'spec_helper'
require 'support/auth_helper'

describe "Beats" do

  include AuthHelper

  describe "/login" do
  	it "should log in the user to Beats" do
  		post "/beats/login", {:username => 'rsnorman15@gmail.com', :password => 'wambam15'}, {}

  		response.should be_ok
      JSON.parse(response.body)['user_id'].should_not be_nil
  		JSON.parse(response.body)['auth_token'].should_not be_nil
  	end

  	it "should not log in the user to Beats with bad credentials" do
  		post "/beats/login", {:username => 'rsnorman15@gmail.com', :password => 'badpassword'}, {}

      response.status.should eq 401
  	end
  end

  describe "/favorite_tracks" do
  	before :each do
  		@client = BeatsWrapper.new(BeatsWrapper::BEATS_TEST_USER_ID, BeatsWrapper::BEATS_TEST_AUTH_TOKEN)
  	end

  	after :each do 
      @client.unfavorite(Track.first)
  		@client.remove_from_library(Track.first)
  	end

  	it "should favorite all tracks saved in mog" do
  		post "/beats/favorite_tracks", {:limit => 1}, auth_parameters

      tracks = JSON.parse(response.body)

      tracks["favorited_tracks"].size.should eq 1
      tracks["favorited_tracks"].first["track_name"].should eq "Mess On A Mission"
      # tracks["missing_tracks"].size.should eq 0
      tracks["error_tracks"].size.should eq 0
  		@client.is_favorited?(Track.first).should be true
  	end

    it "should add all tracks to beats library saved in mog" do
      post "/beats/favorite_tracks", {:limit => 1}, auth_parameters

      tracks = JSON.parse(response.body)

      tracks["favorited_tracks"].size.should eq 1
      tracks["favorited_tracks"].first["track_name"].should eq "Mess On A Mission"
      # tracks["missing_tracks"].size.should eq 0
      tracks["error_tracks"].size.should eq 0
      @client.is_in_library?(Track.first).should be true
    end

    it "should favorite all tracks saved in mog from start position" do
      post "/beats/favorite_tracks", {:start_position => 1, :limit => 1}, auth_parameters

      tracks = JSON.parse(response.body)

      tracks["favorited_tracks"].size.should eq 1
      tracks["favorited_tracks"].first["track_name"].should eq "Seasons (Waiting On You)"
      # tracks["missing_tracks"].size.should eq 0
      tracks["error_tracks"].size.should eq 0
      @client.is_favorited?(Track.first).should be true
    end

    it "should add all tracks to beats library saved in mog from start position" do
      post "/beats/favorite_tracks", {:start_position => 1, :limit => 1}, auth_parameters

      tracks = JSON.parse(response.body)

      tracks["favorited_tracks"].size.should eq 1
      tracks["favorited_tracks"].first["track_name"].should eq "Seasons (Waiting On You)"
      # tracks["missing_tracks"].size.should eq 0
      tracks["error_tracks"].size.should eq 0
      @client.is_in_library?(Track.first).should be true
    end
  end

  describe "/favorite_albums" do
    before :each do
      @client = BeatsWrapper.new(BeatsWrapper::BEATS_TEST_USER_ID, BeatsWrapper::BEATS_TEST_AUTH_TOKEN)
    end

    after :each do 
      @client.unfavorite(Album.first)
    end
    
    it "should favorite all albums saved in mog" do
      post "/beats/favorite_albums", {:limit => 1}, auth_parameters
      @client.is_favorited?(Album.first).should be true
    end
  end

  describe "/favorite_artists" do
  	before :each do
  		@client = BeatsWrapper.new(BeatsWrapper::BEATS_TEST_USER_ID, BeatsWrapper::BEATS_TEST_AUTH_TOKEN)
  	end

  	after :each do
  		@client.unfollow(Artist.first)
  	end
  	
  	it "should favorite all artists saved in mog" do
  		post "/beats/favorite_artists", {:limit => 1}, auth_parameters
  		@client.is_followed?(Artist.first).should be true
  	end
  end
end