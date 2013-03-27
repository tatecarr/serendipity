class HomeController < ApplicationController


	def index


		user = FbGraph::User.me(current_user.access_token)

		user = FbGraph::User.fetch('tate.carr')

		puts 'User-----', user.name, '-----User'

		@picture_url = user.picture

puts user.inspect



		user = FbGraph::User.fetch('tate.carr', :access_token => current_user.access_token)

		@friends = user.friends
		puts 'Friend-----', @friends.length, '-----Friend'


		respond_to do |format|
      		format.html # index.html.erb
      	end
	end


end
