class HomeController < ApplicationController


	def index



		@friends = []
		@likes = []
		@locs = []


		@graph = Koala::Facebook::API.new(current_user.access_token)
		


		profile = @graph.get_object('me')


		respond_to do |format|
			format.html # index.html.erb
		end
	end

	def my_friends

		@graph = Koala::Facebook::API.new(current_user.access_token)
		
		@friends = @graph.get_connections('me', 'friends')

		puts @friends[0].inspect

		respond_to do |format|
			format.html # index.html.erb
		end
	end

	def my_photos

		@graph = Koala::Facebook::API.new(current_user.access_token)
		

		@pictures = params[:page] ? @graph.get_page(params[:page]) : @graph.get_connections('me', 'photos')


		# puts 'Pictures-----',@pictures.inspect,'-----Pictures'



		respond_to do |format|
			format.html
		end

	end

	def my_feed

		@graph = Koala::Facebook::API.new(current_user.access_token)
		

		@feed = params[:page] ? @graph.get_page(params[:page]) : @graph.get_connections('me', 'feed')


		respond_to do |format|
			format.html
		end

	end


	def locations

		@graph = Koala::Facebook::API.new(current_user.access_token)
		
		@locs = params[:page] ? @graph.get_page(params[:page]) : @graph.get_connections('me', 'locations')

		respond_to do |format|
			format.html
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
