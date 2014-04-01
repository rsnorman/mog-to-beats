class Playlist
	attr_accessor :name, :url, :beats_id, :tracks
	attr_reader :tracks

	def initialize(name, url, tracks = nil)
		@name = name
		@url = url
		@tracks = tracks
	end

	# def tracks
	# 	return @tracks if @tracks
	# 	response = MogWrapper.agent.get(@url)
	# 	@tracks = JSON.parse(response.body)["tracks"].collect do |t|

	# 		track = Track.find_by_mog_id(t["track_id"])

	# 		if track.nil?
	# 			track = Track.create(:album_name => t["album_name"], 
	# 					  :track_name => t["track_name"],
	# 					  :artist_name => t["artist_name"],
	# 					  :mog_id => t["track_id"])
	# 		end

	# 		track
	# 	end
	# end

	def delete
		BeatsWrapper.agent.delete()
	end
end