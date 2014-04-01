class CreateAlbum < ActiveRecord::Migration
  def change
  	create_table :albums do |t|
		t.string :album_name
		t.string :artist_name
		t.string :mog_id
		t.string :beats_id
		t.string :spotify_id
	end	
  end
end
