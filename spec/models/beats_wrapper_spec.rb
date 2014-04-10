require 'spec_helper'

describe BeatsWrapper do
	before :all do
		@client = BeatsWrapper.new
		@client.login('rsnorman15@gmail.com', 'wambam15')
	end

	describe "initialize" do
		it "should create an agent with cookies loaded if cookie jar path is provided" do
			client = BeatsWrapper.new(Rails.root.join('cookie_jars', 'rsnorman15@gmail.com'))
			client.is_logged_in.should be_true
			
			track = Track.create(:track_name => "Wet Hair", 
				:album_name => "Post-Nothing", 
				:artist_name => "Japandroids",
				:mog_id => "30596455")
			beats_track = client.search(track)
			beats_track.track_name.should eq "Wet Hair"
		end
	end

	describe "login" do
		it "should login in a user" do
			@client.login('rsnorman15@gmail.com', 'wambam15').should be_true
		end

		it "should not login in a user with incorrect credentials" do
			@client.login('rsnorman15@gmail.com', 'badpassword').should be_false
		end
	end

	describe "search" do
		it "should return a song that matches the query" do
			@track = Track.create(:track_name => "Wet Hair", 
				:album_name => "Post-Nothing", 
				:artist_name => "Japandroids",
				:mog_id => "30596455")
			beats_track = @client.search(@track)
			beats_track.track_name.should eq "Wet Hair"
			beats_track.album_name.should eq "Post-Nothing"
			beats_track.artist_name.should eq "Japandroids"
			beats_track.beats_id.should eq "tr30596457"
		end

		it "should save the beats id in the database" do
			@track = Track.create(:track_name => "Wet Hair", 
				:album_name => "Post-Nothing", 
				:artist_name => "Japandroids",
				:mog_id => "30596455")
			beats_track = @client.search(@track)
			@track.reload.beats_id.should eq "tr30596457"
		end

		it "should find a track with a single quote in the title" do
			@track = Track.create(:track_name => "I Don't Know How",
				:album_name => "Fade Away",
				:artist_name => "Best Coast",
				:mog_id => "91240461")

			beats_track = @client.search(@track)
			@track.reload.beats_id.should eq "tr91240461"
		end

		it "should find a track with an ampersand in the title" do
			@track = Track.create(:track_name => "Lariat",
				:artist_name => "Stephen Malkmus & The Jicks")

			beats_track = @client.search(@track)
			@track.reload.beats_id.should eq "tr94754583"
		end

		it "should find a track with extra content in track name surrouned by parantheses" do
			@track = Track.create(:track_name => "Lines (Album Version)",
				:artist_name => "Big Boi")

			beats_track = @client.search(@track)
			@track.reload.beats_id.should eq "tr77532545"
		end

		it "should find a track with two artists listed when one is featured separated by and 'and'" do
			@track = Track.create(:track_name => "25 Bucks",
				:artist_name => "Danny Brown And Purity Ring")

			beats_track = @client.search(@track)
			@track.reload.beats_id.should eq "tr90030315"
		end

		it "should find a track that is difficult to find" do
			@track = Track.create(:track_name => "Baby Missiles",
				:artist_name => "The War On Drugs")

			beats_track = @client.search(@track)
			@track.reload.beats_id.should eq "tr100537941"
		end

		it "should find a track that has an unnamable artist" do
			@track = Track.create(:track_name => "Even When The Water's Cold",
				:artist_name => "!!!")

			beats_track = @client.search(@track)
			@track.reload.beats_id.should eq "tr83204327"
		end

		it "should find a track that has an and in the name but the result has an ampersand" do
			@track = Track.create(:track_name => "Wait And See",
				:artist_name => "Holy Ghost!")

			beats_track = @client.search(@track)
			@track.reload.beats_id.should eq "tr51933051"
		end


		it "should return an album that matches the query" do
			album = Album.create( 
				:album_name => "Merriweather Post Pavilion", 
				:artist_name => "Animal Collective",
				:mog_id => "")
			beats_track = @client.search(album)
			beats_track.album_name.should eq "Merriweather Post Pavilion"
			beats_track.artist_name.should eq "Animal Collective"
			beats_track.beats_id.should eq "al101137545"
		end

		it "should save the beats id in the database" do
			album = Album.create( 
				:album_name => "Merriweather Post Pavilion", 
				:artist_name => "Animal Collective",
				:mog_id => "")
			beats_track = @client.search(album)
			
			album.reload.beats_id.should eq "al101137545"
		end
	end

	context "track" do
		describe "#favorite" do
			before :each do
				@track = Track.create(:track_name => "Wet Hair", 
					:album_name => "Post-Nothing", 
					:artist_name => "Japandroids",
					:mog_id => "30596455",
					:beats_id => "tr30596457")
				@client.unfavorite(@track)
			end

			after :each do
				@client.unfavorite(@track)
			end

			it "should favorite a song that matches the track id" do
				@client.favorite(@track)
				@client.is_favorited?(@track).should be_true
			end
		end

		describe "#unfavorite" do
			before :each do
				@track = Track.create(:track_name => "Wet Hair", 
					:album_name => "Post-Nothing", 
					:artist_name => "Japandroids",
					:mog_id => "30596455",
					:beats_id => "tr30596457")
				@client.favorite(@track)
			end

			it "should unfavorite a song that matches the track id" do
				@client.unfavorite(@track)
				@client.is_favorited?(@track).should be_false
			end
		end

		describe "#add_to_library" do
			before :each do
				@track = Track.create(:track_name => "Wet Hair", 
					:album_name => "Post-Nothing", 
					:artist_name => "Japandroids",
					:mog_id => "30596455",
					:beats_id => "tr30596457")
				@client.remove_from_library(@track)
			end

			after :each do
				@client.remove_from_library(@track)
			end

			it "should add a song to the library that matches the track id" do
				@client.add_to_library(@track)
				@client.is_in_library?(@track).should be_true
			end
		end

		describe "#remove_from_library" do
			before :each do
				@track = Track.create(:track_name => "Wet Hair", 
					:album_name => "Post-Nothing", 
					:artist_name => "Japandroids",
					:mog_id => "30596455",
					:beats_id => "tr30596457")
				@client.add_to_library(@track)
			end

			it "should remove a song from the library that matches the track id" do
				@client.remove_from_library(@track)
				@client.is_in_library?(@track).should be_false
			end
		end
	end

	context "album" do
		describe "#favorite" do
			before :each do
				@album = Album.create(
					:album_name => "Post-Nothing", 
					:artist_name => "Japandroids",
					:mog_id => "30596455",
					:beats_id => "al31504333")
				@client.unfavorite(@album)
			end

			after :each do
				@client.unfavorite(@album)
			end

			it "should favorite a song that matches the album id" do
				@client.favorite(@album)
				@client.is_favorited?(@album).should be_true
			end
		end

		describe "#unfavorite" do
			before :each do
				@album = Album.create(:album_name => "Wet Hair", 
					:album_name => "Post-Nothing", 
					:artist_name => "Japandroids",
					:mog_id => "30596455",
					:beats_id => "tr30596457")
				@client.favorite(@album)
			end

			it "should unfavorite a song that matches the album id" do
				@client.unfavorite(@album)
				@client.is_favorited?(@album).should be_false
			end
		end
	end

	describe "#create_playlist" do
		after :each do
			@client.delete_playlist(@playlist_id) if @playlist_id
		end

		it "should create a playlist" do
			@playlist_id = @client.create_playlist("Test")["data"]["id"]
		end
	end

	describe "add_track_to_playlist" do
		before :each do 
			@track = Track.create(:track_name => "Wet Hair", 
				:album_name => "Post-Nothing", 
				:artist_name => "Japandroids",
				:mog_id => "30596455",
				:beats_id => "tr30596457")

			@playlist = Playlist.new("Test", "")
			@playlist.beats_id = "pl163465127599931648"
		end

		it "should add a track to a playlist" do
			@client.add_track_to_playlist(@playlist, @track).should be_true
		end
	end
end