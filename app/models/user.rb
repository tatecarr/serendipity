class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:facebook]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :provider, :uid, :access_token
  # attr_accessible :title, :body

  def person
  	Person.find_by_uid(self.uid)
  end


  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)

  	puts auth.inspect

  	puts 'Token----',auth.token,auth.credentials.token,'-----Token'

	  user = User.where(:provider => auth.provider, :uid => auth.uid).first
	  unless user

	  	# name:auth.extra.raw_info.name,
	    
	    user = User.create(
	                         provider:auth.provider,
	                         uid:auth.uid,
	                         access_token:auth.credentials.token,
	                         email:auth.info.email,
	                         password:Devise.friendly_token[0,20]
	                         )

	  end
	  user

	end


	def self.populate_fb_person_record(user)


		@graph = Koala::Facebook::API.new(user.access_token)

      #people table
      me = @graph.get_object('me')

      format_date = nil
      birthday_ymd = nil
      unless me['birthday'].blank?
        split_date = me['birthday'].split('/')
        birthday_ymd = Ymddate.get_or_create(split_date[2], split_date[0], split_date[1])
        format_date = split_date[2] + '/' + split_date[0] + '/' + split_date[1]
      end

      interested_in_list = me['interested_in'].join(',') if me['interested_in']

      #<TODO> -- NEED TO CHECK IF THIS RECORD ALREADY EXISTS -- I THINK WE WANT TO CREATE A PERSON FOR EACH FRIEND IN FACEBOOK ETC.  AND THEN INSTEAD OF HAVING
      # A FRIENDS TABLE, WE'LL CREATE A RELATIONSHIP BETWEEN PEOPLE CALLED FRIENDS -- CAN ALSO CREATE FAMILY MEMBER RELATIONSHIPS -- ITERATING OVER FAMILY NEEDS
      # TO BE ADDED AS WELL.
      #
      # PERSON.FIND_BY_UID(...)

      new_person = nil
      existing_person = Person.find_by_uid(user.uid)

      logger.debug 'me["name"] => ' + me['name']

      if existing_person.blank?

      	logger.debug 'Person blank / does not exist'

	      new_person = Person.create(
	        uid: user.uid,
	        name: me['name'],
	        first_name: me['first_name'],
	        last_name: me['last_name'],
	        fb_link: me['link'],
	        fb_username: me['username'],
	        birthday: format_date,
	        gender: me['gender'],
	        interested_in: interested_in_list,
	        political: me['political'],
	        email: me['email'],
	        timezone: me['timezone'],
	        locale: me['locale'],
	        person_populated: 1
	      )

	    elsif existing_person.person_populated != true

	    	logger.debug 'Person not blank and person_populated != 1'

	    	existing_person.name = me['name']
        existing_person.first_name = me['first_name']
        existing_person.last_name = me['last_name']
        existing_person.fb_link = me['link']
        existing_person.fb_username = me['username']
        existing_person.birthday = format_date
        existing_person.gender = me['gender']
        existing_person.interested_in = interested_in_list
        existing_person.political = me['political']
        existing_person.email = me['email']
        existing_person.timezone = me['timezone']
        existing_person.locale = me['locale']
        existing_person.person_populated = 1
        existing_person.save
        new_person = existing_person

      else

      	logger.debug 'Person not blank BUT person_populated == 1'
      	return 1

	    end


# puts 'Gets to here-----'
# puts birthday_ymd,birthday_ymd.id,'after'


      unless birthday_ymd.blank?
	      Relationship.create(
          source_id:new_person.id,
          source_type:EntityType.get_entity_type_id('Person'),
          target_id:birthday_ymd.id,
          target_type:EntityType.get_entity_type_id('Date'),
          relationship_type:RelationshipType.get_relationship_type_id('Birthday')
        )
	    end

puts 'Gets to here 2-----'


      # Current user hometown and current Location
      hometown = Place.get_fb_info_by_page_id(user.access_token, me['hometown']['id'])
      hometown_lat = hometown['location']['latitude']
      hometown_long = hometown['location']['longitude']
      hometown_name = hometown['name']
      hometown_cat = hometown['category']

puts 'hometown-----',hometown_lat,hometown_long,hometown_name,hometown_cat,'hometown-----'

      hometown_record = Place.get_or_create(hometown_lat, hometown_long, hometown_name, hometown_cat)

      Relationship.create(
          source_id:new_person.id,
          source_type:EntityType.get_entity_type_id('Person'),
          target_id:hometown_record.id,
          target_type:EntityType.get_entity_type_id('Place'),
          relationship_type:RelationshipType.get_relationship_type_id('Hometown')
        )



      # populate_notable_people(hometown_record)



      curr_location = Place.get_fb_info_by_page_id(user.access_token, me['location']['id'])
      curr_location_record = Place.get_or_create(
          curr_location['location']['latitude'],
          curr_location['location']['longitude'],
          curr_location['name'],
          curr_location['category']
        )

      Relationship.create(
          source_id:new_person.id,
          source_type:EntityType.get_entity_type_id('Person'),
          target_id:curr_location_record.id,
          target_type:EntityType.get_entity_type_id('Place'),
          relationship_type:RelationshipType.get_relationship_type_id('CurrentLocation')
        )


      # populate_notable_people(curr_location_record)



      # PLACE
      # <TODO> need to get lat/lon for places that don't have it???


      #education
      ed = me['education']
      ed.each do |ed_elem|

        ed_details = @graph.get_object(ed_elem['school']['id'])
        ed_addr = ed_details['location']['city'] + ', ' + ed_details['location']['state'] + ', ' + ed_details['location']['country']

        lat_long = Place.geocode_location(ed_addr)

        tmp_place = Place.get_or_create(lat_long['lat'], lat_long['long'], ed_elem['school']['name'], ed_elem['type'])

        # tmp_ed = PersonEducation.create(
        #   person_id: new_person.id,
        #   education_id: ed_elem['school']['id'],
        #   name: ed_elem['school']['name'],
        #   type_desc: ed_elem['type']
        # )

        Relationship.create(
          source_id:new_person.id,
          source_type:EntityType.get_entity_type_id('Person'),
          target_id:tmp_place.id,
          target_type:EntityType.get_entity_type_id('Place'),
          relationship_type:RelationshipType.get_relationship_type_id(ed_elem['type'])
        )

      end


      #<TODO> need to add friends as a Relationship record not separate table
      #friends
      friends = @graph.get_connections('me', 'friends')
      friends.each do |f|


      	# lookup the friend by UID, 
      	tmp_friend = Person.find_by_uid(f['id'])

      	# if not found, create a person record first
      	if tmp_friend.blank?

      		tmp_friend = Person.create(
		        uid: f['id'],
		        name: f['name']
		      )

      	end

      	# if found, we do not create a Person record but do create a relationship between the two as Friend
      	# now create relationship between the two since we'll have the friend's person record one way or another
      	Relationship.create(
          source_id:new_person.id,
          source_type:EntityType.get_entity_type_id('Person'),
          target_id:tmp_friend.id,
          target_type:EntityType.get_entity_type_id('Person'),
          relationship_type:RelationshipType.get_relationship_type_id('Friend')
        )

      end


      # "locations" are many different things in FB that have had location added e.g. Posts, Photos, Status
			#
			# Adding relationship as "Checkin" because these are photos, places, etc. that get returned by the FB "locations" connection
			#      
      locations = @graph.get_connections('me', 'locations')
      locations.each do |loc|

        loc_name = loc['place']['name'] if loc['place']
        loc_lat = loc['place']['location']['latitude'] if loc['place'] && loc['place']['location']
        loc_long = loc['place']['location']['longitude'] if loc['place'] && loc['place']['location']
        loc_date = loc['created_time'].to_date
        loc_ymddate = Ymddate.get_or_create(loc_date.year, loc_date.month, loc_date.day) unless loc_date.blank?
        loc_ymddate_id = loc_ymddate.id unless loc_ymddate.blank?

        # changing to be checkin 
        # <TODO> Need to keep the 'type' as well though?  This is photo, status (and maybe more) -- could 'checkin' to a certain location many, many
        # 	times -- do we want to keep this too and have a separate relationship_detail/"instances" table?  So it's kind of header/detail relationship?
        loc_src = 'Checkin' # loc['type']

        loc_id = loc['place']['id'] if loc['place']
        loc_details = @graph.get_object(loc_id) if !loc_id.blank?
        loc_type = loc_details['category'] if loc_details


        tmp_place = Place.get_or_create(loc_lat, loc_long, loc_name, loc_type)


        Relationship.create_ignore_dupe(
          new_person.id,
          EntityType.get_entity_type_id('Person'),
          tmp_place.id,
          EntityType.get_entity_type_id('Place'),
          RelationshipType.get_relationship_type_id(loc_src),
          loc_date,
          loc_ymddate_id
        )

      end



      # THINGS?  <TODO> Need to map the category to whether a PLACE or a THING?
      #likes
      likes = @graph.get_connections('me', 'likes')
      likes.each do |l|

        tmp_like_id = l['id']

        tmp_like = @graph.get_object(tmp_like_id)

        if tmp_like['location'].blank?

          tmp_thing = Thing.get_or_create(l['name'], l['category'])

          Relationship.create(
            source_id:new_person.id,
            source_type:EntityType.get_entity_type_id('Person'),
            target_id:tmp_thing.id,
            target_type:EntityType.get_entity_type_id('Thing'),
            relationship_type:RelationshipType.get_relationship_type_id('Like')
          )

        else

          loc_name = tmp_like['name']
          loc_lat = tmp_like['location']['latitude']
          loc_long = tmp_like['location']['longitude']
          loc_cat = tmp_like['category']

          tmp_place = Place.get_or_create(loc_lat, loc_long, loc_name, loc_cat)

          Relationship.create(
            source_id:new_person.id,
            source_type:EntityType.get_entity_type_id('Person'),
            target_id:tmp_place.id,
            target_type:EntityType.get_entity_type_id('Place'),
            relationship_type:RelationshipType.get_relationship_type_id('Like')
          )

        end

      end

      user.person_populated = 1
      user.save


	end


	def self.delete_all_a_users_stuff(user)

		person_name = '(Unknown)'
		person_deleted = 0
		src_rel_deleted = 0
		tgt_rel_deleted = 0
		pf_deleted = 0

		person_type_id = EntityType.get_entity_type_id('Person')
		curr_user_person = user.person

		if curr_user_person
			curr_person_id = curr_user_person.id


			# <TODO> should probably restrict this to not delete FRIEND and potentially other relationships -- for Friend it possibly should
			# only be the relationships where the user is the source???!!!

			src_rel_deleted = Relationship.where(:source_id => curr_person_id, :source_type => person_type_id).delete_all
			tgt_rel_deleted = Relationship.where(:target_id => curr_person_id, :target_type => person_type_id).delete_all


			tmp_person = Person.find_by_uid(user.uid)
			if tmp_person
				person_name = tmp_person.name
				tmp_person.delete
				person_deleted = 1
			end
		end

		user.person_populated = 0
		user.save

		puts 'Name: ' + person_name, 'Deleted person? ' + person_deleted.to_s, 'Src relations deleted: ' + src_rel_deleted.to_s, 'Tgt relations deleted: ' + tgt_rel_deleted.to_s, '---------------'

	end


	def self.remove_all_support_records(phrase)

		if phrase == 'stlcardinals'

			Person.delete_all
			Place.delete_all
			RelationshipType.delete_all
			Relationship.delete_all
			PopulatedInfo.delete_all
			Thing.delete_all
			Ymddate.delete_all

		else
			puts 'Please put in the phrase to make sure you really want to do this.  It could take a little bit.'
		end
		
	end

	def self.refresh_all_user_data(phrase)


		if phrase == 'stlcardinals'

			num_users_updated = 0
		
			User.all.each do |curr_user|

				User.delete_all_a_users_stuff(curr_user)
				User.populate_fb_person_record(curr_user)
				num_users_updated += 1

			end

			puts '', num_users_updated.to_s + ' users data refreshed', ''

		else
			puts 'Please put in the phrase to make sure you really want to do this.  It could take a little bit.'
		end


	end


	private

	def self.populate_notable_people(location_record)

		sparql = SPARQL::Client.new("http://dbpedia.org/sparql")

		location_name = location_record['name']

		puts 'Start the DBpedia searching-----'
    us_states_array = ['Alabama','Alaska','Arizona','Arkansas','California','Colorado','Connecticut','Delaware','Florida','Georgia','Hawaii','Idaho','Illinois','Indiana','Iowa','Kansas','Kentucky','Louisiana','Maine','Maryland','Massachusetts','Michigan','Minnesota','Mississippi','Missouri','Montana','Nebraska','Nevada','New Hampshire','New Jersey','New Mexico','New York','North Carolina','North Dakota','Ohio','Oklahoma','Oregon','Pennsylvania','Rhode Island','South Carolina','South Dakota','Tennessee','Texas','Utah','Vermont','Virginia','Washington','West Virginia','Wisconsin','Wyoming']

    # <TODO> who knows how many variations there could be with this, probably needs to be real robust
    # Get the people that have this as a birthplace
    # Need to extract the DBPedia search criteria -- for USA use the full name, else split to get city/country
    # if there is a comma, split on the comma
    hometown_array = (!location_name.blank? && location_name.include?(',')) ? location_name.split(',') : []

    consolodated_results = Hash.new
    result = nil

    if hometown_array.size == 2

    	if us_states_array.include?(hometown_array[1].strip)
    		# use just the name as the search term
    		puts '---it is a US state'

    		underscored_name = location_name.gsub(' ','_')

				query = 'PREFIX geo: <http://www.w3.org/2003/01/geo/wgs84_pos#>
				PREFIX dbpedia-owl: <http://dbpedia.org/ontology/>
				PREFIX dbpedia: <http://dbpedia.org/resource/>
				PREFIX foaf: <http://xmlns.com/foaf/0.1/>

				SELECT DISTINCT ?person ?name ?bday ?birthplace
				WHERE 
				{
				  ?person a dbpedia-owl:Person ;
				           dbpedia-owl:birthPlace ?birthplace .

				  ?birthplace foaf:name "'+location_name+'"@en .
				  
				  ?person dbpprop:name ?name .

				  optional {
				  	?person dbpprop:birthDate ?bday
				  }
				}'

				puts query
				puts '-----pre DBPedia result'

				result = sparql.query(query)

				puts '-----Post DBPedia result'


				# if the result size is 0 - might not have same cateogorizations for attributes.  try foaf:label
				if result.size == 0

					query = 'PREFIX geo: <http://www.w3.org/2003/01/geo/wgs84_pos#>
					PREFIX dbpedia-owl: <http://dbpedia.org/ontology/>
					PREFIX dbpedia: <http://dbpedia.org/resource/>
					PREFIX foaf: <http://xmlns.com/foaf/0.1/>

					SELECT DISTINCT ?person ?name ?bday ?birthplace
					WHERE 
					{
					  ?person a dbpedia-owl:Person ;
					           dbpedia-owl:birthPlace ?birthplace .

					  ?birthplace rdfs:label "'+location_name+'"@en .
					  
					  ?person dbpprop:name ?name .

					  optional {
					  	?person dbpprop:birthDate ?bday
					  }
					}'

					puts query
					puts '-----pre DBPedia result'

					result = sparql.query(query)

					puts '-----Post DBPedia result'

				end

    	else
    		# use the first element as city, second as country since not a state in the US

				query = 'PREFIX geo: <http://www.w3.org/2003/01/geo/wgs84_pos#>
				PREFIX dbpedia-owl: <http://dbpedia.org/ontology/>
				PREFIX dbpedia: <http://dbpedia.org/resource/>
				PREFIX foaf: <http://xmlns.com/foaf/0.1/>

				SELECT DISTINCT ?person ?name ?bday ?birthplace ?lat1 ?long1
				WHERE 
				{
				  ?person a dbpedia-owl:Person ;
				           dbpedia-owl:birthPlace ?birthplace .

				  ?birthplace foaf:name "'+hometown_array[0].strip+'"@en .

				  ?birthplace dbpedia-owl:country dbpedia:'+hometown_array[1].strip.gsub(' ','_')+'

				  
				  optional {
				    ?birthplace geo:lat ?lat1 .
				    ?birthplace geo:long ?long1 .
				  }

				  optional {
				  	?person dbpprop:name ?name
				  }
				  optional {
				  	?person dbpprop:birthDate ?bday
				  }
				}'

				puts query
				puts '-----pre DBPedia result'

				result = sparql.query(query)

				puts '-----Post DBPedia result'


    	end

			puts 'SPARQL-----'
			
			result.each do |res|

				tmp_uri = res[:person].to_s
				tmp_name = res[:name].to_s
				tmp_birthday = res[:bday].to_s

				unless consolodated_results.include?(tmp_uri)
					consolodated_results[tmp_uri] = {'name' => tmp_name, 'birthday' => tmp_birthday}
				end

				

				puts '', res.inspect, ''
			end
			puts 'SPARQL-----'

    end

    test_date_string = ""

    consolodated_results.each do |con_res_id, con_res_vals|

	    tmp_format_date = nil
	    tmp_birthday_ymd = nil
	    unless con_res_vals['birthday'].blank?

	    	test_date_string += con_res_vals['birthday'] + "\n"

	      split_date = con_res_vals['birthday'].split('-') # this is hyphen for DBpedia birthdays looks like -- but FB uses '/'
	      
	      if !split_date.blank? && split_date.size == 3
	      	puts 'VALID BIRTHDAY',''
		      tmp_birthday_ymd = Ymddate.get_or_create(split_date[0], split_date[1], split_date[2])
		      tmp_format_date = con_res_vals['birthday']
		    end

	    end


	    tmp_new_person = Person.get_or_create(
        con_res_vals['name'],
        tmp_format_date,
        con_res_id
      )




      unless tmp_birthday_ymd.blank?
	      Relationship.create(
          source_id:tmp_new_person['id'],
          source_type:EntityType.get_entity_type_id('Person'),
          target_id:tmp_birthday_ymd['id'],
          target_type:EntityType.get_entity_type_id('Date'),
          relationship_type:RelationshipType.get_relationship_type_id('Birthday')
        )
	    end


	    birthplace_relation = Relationship.where(:source_id => tmp_new_person.id, :source_type => EntityType.get_entity_type_id('Person'),
	    	:relationship_type => RelationshipType.get_relationship_type_id('Birthplace'))

	    unless birthplace_relation.size > 0
	    	Relationship.create(
          source_id:tmp_new_person['id'],
          source_type:EntityType.get_entity_type_id('Person'),
          target_id:location_record['id'],
          target_type:EntityType.get_entity_type_id('Place'),
          relationship_type:RelationshipType.get_relationship_type_id('Birthplace')
        )
	    end


	  end

	  puts test_date_string
		
	end



end
