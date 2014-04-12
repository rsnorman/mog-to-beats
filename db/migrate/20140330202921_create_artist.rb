class CreateArtist < ActiveRecord::Migration
  def change
  	create_table :artists do |t|
		t.string :artist_name
		t.string :mog_id
		t.string :beats_id
		t.string :spotify_id
	end	
  end
end
