require 'spec_helper'
require 'support/auth_helper'

describe "Beats" do

  include AuthHelper

  describe "/login" do
  	it "should log in the user to Beats" do
  		post "/beats/login", {:username => 'rsnorman15@gmail.com', :password => 'wambam15'}, {}

  		response.should be_ok
  		JSON.parse(response.body)['success'].should be_true
  	end

  	it "should not log in the user to Beats with bad credentials" do
  		post "/beats/login", {:username => 'rsnorman15@gmail.com', :password => 'badpassword'}, {}

  		response.should be_ok
  		JSON.parse(response.body)['success'].should be_false
  	end
  end

  describe "/favorite_tracks" do
  	before :each do
  		@client = BeatsWrapper.new('rsnorman15@gmail.com')
  	end

  	after :each do 
  		@client.unfavorite(Track.first)
  	end

  	it "should favorite all tracks saved in mog" do
  		post "/beats/favorite_tracks", {:limit => 1}, auth_parameters

  		@client.is_favorited?(Track.first).should be true
  	end
  end

  describe "/favorite_albums" do
  	before :each do
  		@client = BeatsWrapper.new('rsnorman15@gmail.com')
  	end

  	after :each do 
  		@client.unfavorite(Album.first)
  	end
  	
  	it "should favorite all albums saved in mog" do
  		post "/beats/favorite_albums", {:limit => 1}, auth_parameters
  		puts Album.first.inspect
  		@client.is_favorited?(Album.first).should be true
  	end
  end
end