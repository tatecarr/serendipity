class HomeController < ApplicationController


	def index



		@friends = []
		@likes = []
		@locs = []


		@graph = Koala::Facebook::API.new(current_user.access_token)
		

		profile = @graph.get_object('me')

		likes = @graph.get_connections('me', 'friends')

		puts '-----Likes', profile, '-----Likes'


		sparql = SPARQL::Client.new("http://dbpedia.org/sparql")

		# query = 'PREFIX prop: <http://dbpedia.org/property/>

		# 					select ?place ?name ?pop_total ?lat ?long
		# 					where
		# 					{
							    
		# 					    # ?place foaf:name "'++'" ;
		# 					    ?place rdf:type yago:TownsInVermont ;
		# 					    		foaf:name "Middletown Springs, Vermont"@en ;
		# 					        dbpedia-owl:populationTotal ?pop_total ;
		# 					        geo:lat ?lat ;
		# 					        geo:long ?long .

		# 					}'

    # rdf:type dbpedia-owl:Place ;
    # FILTER regex(?name, "Middletown Springs")

		# result = sparql.query(query)

		# puts 'SPARQL-----'
		# result.each do |res|
		# 	puts '', res.inspect, ''
		# end
		# puts 'SPARQL-----'


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

	def delete_all_my_stuff
		
		# PersonEducation.find_by_
		person_type_id = EntityType.get_entity_type_id('Person')
		curr_user_person = current_user.person

		if curr_user_person
			curr_person_id = curr_user_person.id

			@src_rel_deleted = Relationship.where(:source_id => curr_person_id, :source_type => person_type_id).delete_all
			@tgt_rel_deleted = Relationship.where(:target_id => curr_person_id, :target_type => person_type_id).delete_all

			@pf_deleted = PersonFriend.where(:person_id => curr_person_id).delete_all

			tmp_person = Person.find_by_uid(current_user.uid)
			if tmp_person
				@person_deleted = tmp_person.delete
			else
				@person_deleted = 0
			end
		end

		current_user.person_populated = 0
		current_user.save

	end



end
