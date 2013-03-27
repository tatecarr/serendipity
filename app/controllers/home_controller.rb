class HomeController < ApplicationController


	def index


		the_id = params['uid'] || current_user.uid

		# user = FbGraph::User.me(current_user.access_token)

		user = FbGraph::User.fetch(the_id)

		puts 'User-----', user.inspect, '-----User'

		@picture_url = user.picture

puts user.inspect



		user = FbGraph::User.fetch(the_id, :access_token => current_user.access_token)

		@friends = user.friends
		puts 'Friend-----', @friends.length, '-----Friend'

		# ff_id = @friends.first.raw_attributes['id']
		# puts 'ff_id',ff_id,''
		# ff = FbGraph::User.fetch(ff_id, :access_token => current_user.access_token)

		# fffriends = ff.friends

		# puts 'First friend-----', ff.inspect, '-----First friend' #, fffriends.length, '-----ff length'


		respond_to do |format|
			format.html # index.html.erb
		end
	end



	def user_mgmt

		user = FbGraph::User.me(current_user.access_token)

		user = FbGraph::User.fetch('tate.carr')

		puts 'User-----', user.name, '-----User'

		@picture_url = user.picture


		@users = User.all

	end



end
