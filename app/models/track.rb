class Track < ActiveRecord::Base
	attr_accessible :track_name, :album_name, :artist_name, :mog_id, :beats_id
end