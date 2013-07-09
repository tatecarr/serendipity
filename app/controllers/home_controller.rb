class HomeController < ApplicationController


	def index


		@graph = Koala::Facebook::API.new(current_user.access_token)
		

		profile = @graph.get_object('me')

		likes = @graph.get_connections('me', 'friends')

		puts '-----Likes', profile, '-----Likes'


		# sparql = SPARQL::Client.new("http://dbpedia.org/sparql")

		# query = 'PREFIX prop: <http://dbpedia.org/property/>

		# 					select ?place ?name ?pop_total ?lat ?long
		# 					where
		# 					{
							    
		# 					    ?place foaf:name ?name ;
		# 					    rdf:type yago:TownsInVermont ;
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


	def linked_data

		my_person = current_user.person

		@hometown_relationship = Relationship.where(:source_id => my_person.id, :source_type => EntityType.get_entity_type_id('Person'),
			:target_type => EntityType.get_entity_type_id('Place'), :relationship_type => RelationshipType.get_relationship_type_id('Hometown'))

		unless @hometown_relationship.blank?
			@hometown = Place.find(@hometown_relationship.first['target_id'].to_i)

			@hometown_notable_people = get_notable_people(@hometown)
		end


		@current_location_relationship = Relationship.where(:source_id => my_person.id, :source_type => EntityType.get_entity_type_id('Person'),
			:target_type => EntityType.get_entity_type_id('Place'), :relationship_type => RelationshipType.get_relationship_type_id('CurrentLocation'))

		unless @current_location_relationship.blank?
			@current_location = Place.find(@current_location_relationship.first['target_id'].to_i)

			@current_location_notable_people = get_notable_people(@current_location)
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

	def relationships


		s = SerenObj.new


		c = ActiveRecord::Base.connection

    p = Place.find_by_name('Charlotte, North Carolina')

    puts p.inspect

    unless p.blank?

      puts p.lat, p.long

      pt = EntityType.get_entity_type_id('Place')

      @result = c.execute('select * from relationships r where r.target_id = '+p.id.to_s+' and r.target_type = '+pt.to_s)

    end

	end


	def serendipities

		# @place_id = current_user.person # params[:place_id]


		sc = SerenCollection.new

		# unless @place_id.blank?

			@serendipities = sc.get_moments(current_user.person)

		# end


		
	end


private

	#<TODO> This should probably go in the PERSON model since it's person related...
	def get_notable_people(location)

		location_rel = Relationship.where(:target_id => location['id'], :target_type => EntityType.get_entity_type_id('Place'),
				:relationship_type => RelationshipType.get_relationship_type_id('Birthplace'))

		unless location_rel.blank?

			person_id_array = []

			if location_rel.size > 10

				for i in 1..10
					person_id_array.push(location_rel[(location_rel.size*rand).to_i]['source_id'])
				end

			else
				location_rel.each do |rel|
					person_id_array.push(rel['source_id'])
				end
			end

			notable_people = Person.find(person_id_array)

		end

		return { 'notable_people' => notable_people, 'total_number' => location_rel.size }
		
	end

end
