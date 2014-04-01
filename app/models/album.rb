class Album < ActiveRecord::Base
	attr_accessible :album_name, :artist_name, :mog_id, :beats_id
end