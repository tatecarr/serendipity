class DbpediaInfoEngine < ActiveRecord::Base


	# Method to call to update all the external data from Dbpedia and other sources
	# This method can be called from a scheduled task, and this method will call the logic
	# for getting any new information.
	#
	# Will not really include the logic for checking for "updates" to entities which have
	# already had linked external data added.  E.g. the people born in a particular place -
	# this will happen once and down the road logic can be made for checking if info has been
	# updated or if new info is available.
	def self.update_dbpedia_info


		DbpediaInfoEngine.update_place_birthplace_info	# People born in a place


		

	end


	def self.update_movie_cast_crew

		apikey = '72e8b2d9b92fa0078ac6134eb743e8a4'

		Tmdb.api_key = apikey
		Tmdb.default_language = "en"

		person_entity_type_id = EntityType.get_entity_type_id('Person')
		thing_entity_type_id = EntityType.get_entity_type_id('Thing')
		date_entity_type_id = EntityType.get_entity_type_id('Date')
		place_entity_type_id = EntityType.get_entity_type_id('Place')
		release_date_rel_type_id = RelationshipType.get_relationship_type_id('ReleaseDate')
		movie_cast_rel_type_id = RelationshipType.get_relationship_type_id('MovieCast')
		movie_crew_rel_type_id = RelationshipType.get_relationship_type_id('MovieCrew')
		birthday_rel_type_id = RelationshipType.get_relationship_type_id('Birthday')
		deathday_rel_type_id = RelationshipType.get_relationship_type_id('Deathday')
		birthplace_rel_type_id = RelationshipType.get_relationship_type_id('Birthplace')

		info_type_id = DbpediaInfo.get_or_create('MovieCastCrew')

		# get the places that haven't had their "birthplace of" information retrieved yet
		movies_to_update = Thing.where("type_desc = 'Movie' and id not in (select source_id from populated_infos where source_type = ? and dbpedia_info_id = ? and is_populated = ?)", thing_entity_type_id, info_type_id, true)

		movies_to_update.each do |movie|
			
			begin


				ActiveRecord::Base.transaction do


					# get the movie info
					tmdb_movie = TmdbMovie.find(:title => movie.name, :limit => 1)
					
					if tmdb_movie.blank?

						# If the movie is not found -- populate the info record so we don't keep searching for it
						PopulatedInfo.create(source_id:movie.id, source_type:thing_entity_type_id, dbpedia_info_id:info_type_id, is_populated:true)
						DbpediaLog.create(source_id:movie.id, source_type:thing_entity_type_id, info_type_id:info_type_id, status:'success', added_relationships:0, log_message:movie.name)

					else

						# add release date and various relationships for movie

						rd = tmdb_movie.release_date.split('-') unless tmdb_movie.release_date.blank?
						ymddate_id = Ymddate.get_or_create(rd[0], rd[1], rd[2]).id unless rd.blank?

						unless ymddate_id.blank?
							Relationship.create_ignore_dupe(movie.id, thing_entity_type_id, ymddate_id, date_entity_type_id, release_date_rel_type_id, nil, nil)
						end

						# get the movie cast detailed info
						unless tmdb_movie.cast.blank?
							tmdb_movie.cast.each do |tmc|

								curr_cast = TmdbCast.find(:id => tmc.id)

								# create person record, checking if exists with same resource_id and resource_type
								curr_person = Person.get_or_create(curr_cast.name, curr_cast.birthday, curr_cast.id, 'tmdb')

								# create relationship to movie as "MovieCast"
								Relationship.create_ignore_dupe(curr_person.id, person_entity_type_id, movie.id, thing_entity_type_id, movie_cast_rel_type_id, nil, nil)

								# create relationship to birthday date -- Ymddate GET OR CREATE
								bday = curr_cast.birthday.split('-') unless curr_cast.birthday.blank?
								bday_ymddate_id = Ymddate.get_or_create(bday[0], bday[1], bday[2]).id unless bday.blank?

								unless bday_ymddate_id.blank?
									Relationship.create_ignore_dupe(curr_person.id, person_entity_type_id, bday_ymddate_id, date_entity_type_id, birthday_rel_type_id, nil, nil)
								end


								# create relationship to deathday date -- Ymddate GET OR CREATE
								dday = curr_cast.deathday.split('-') unless curr_cast.deathday.blank?
								dday_ymddate_id = Ymddate.get_or_create(dday[0], dday[1], dday[2]).id unless dday.blank?

								unless dday_ymddate_id.blank?
									Relationship.create_ignore_dupe(curr_person.id, person_entity_type_id, dday_ymddate_id, date_entity_type_id, deathday_rel_type_id, nil, nil)
								end

								# create relationship to place of birth location -- Place GET OR CREATE
								lat = nil
								long = nil
								lat_long = nil
								
								unless curr_cast.place_of_birth.blank?
									lat_long = Place.geocode_location(curr_cast.place_of_birth)
								end

								lat = lat_long['lat'] unless lat_long.blank?
								long = lat_long['long'] unless lat_long.blank?

								hometown = Place.get_or_create(lat, long, curr_cast.place_of_birth, 'City') unless curr_cast.place_of_birth.blank?

								Relationship.create_ignore_dupe(curr_person.id, person_entity_type_id, hometown.id, place_entity_type_id, birthplace_rel_type_id, nil, nil) unless hometown.blank?

							end
						end

						# get the movie crew detailed info
						unless tmdb_movie.crew.blank?
							tmdb_movie.crew.each do |tmc|

								curr_crew = TmdbCast.find(:id => tmc.id)

								# create person record, checking if exists with same resource_id and resource_type
								curr_person = Person.get_or_create(curr_crew.name, curr_crew.birthday, curr_crew.id, 'tmdb')

								# create relationship to movie as the "JOB" for the curr_crew -- or use "MovieCrew" if blank
								if tmc.job.blank?
									Relationship.create_ignore_dupe(curr_person.id, person_entity_type_id, movie.id, thing_entity_type_id, movie_crew_rel_type_id, nil, nil)
								else
									crew_job_rel_type_id = RelationshipType.get_relationship_type_id(tmc.job)
									Relationship.create_ignore_dupe(curr_person.id, person_entity_type_id, movie.id, thing_entity_type_id, crew_job_rel_type_id, nil, nil)
								end

								# create relationship to birthday date -- Ymddate GET OR CREATE
								bday = curr_crew.birthday.split('-') unless curr_crew.birthday.blank?
								bday_ymddate_id = Ymddate.get_or_create(bday[0], bday[1], bday[2]).id unless bday.blank?

								unless bday_ymddate_id.blank?
									Relationship.create_ignore_dupe(curr_person.id, person_entity_type_id, bday_ymddate_id, date_entity_type_id, birthday_rel_type_id, nil, nil)
								end


								# create relationship to deathday date -- Ymddate GET OR CREATE
								dday = curr_crew.deathday.split('-') unless curr_crew.deathday.blank?
								dday_ymddate_id = Ymddate.get_or_create(dday[0], dday[1], dday[2]).id unless dday.blank?

								unless dday_ymddate_id.blank?
									Relationship.create_ignore_dupe(curr_person.id, person_entity_type_id, dday_ymddate_id, date_entity_type_id, deathday_rel_type_id, nil, nil)
								end

								# create relationship to place of birth location -- Place GET OR CREATE
								lat = nil
								long = nil
								lat_long = nil
								
								unless curr_crew.place_of_birth.blank?
									lat_long = Place.geocode_location(curr_crew.place_of_birth)
								end

								lat = lat_long['lat'] unless lat_long.blank?
								long = lat_long['long'] unless lat_long.blank?

								hometown = Place.get_or_create(lat, long, curr_crew.place_of_birth, 'City') unless curr_crew.place_of_birth.blank?

								Relationship.create_ignore_dupe(curr_person.id, person_entity_type_id, hometown.id, place_entity_type_id, birthplace_rel_type_id, nil, nil) unless hometown.blank?

							end
						end

						PopulatedInfo.create(source_id:movie.id, source_type:thing_entity_type_id, dbpedia_info_id:info_type_id, is_populated:true)
						DbpediaLog.create(source_id:movie.id, source_type:thing_entity_type_id, info_type_id:info_type_id, status:'success', added_relationships:0, log_message:movie.name + ':  added movie related information')

					end

				end

			rescue => ex_detail

				# Log the current movie and the error message
				# puts 'ERROR-----' + ex_detail.to_s
				# puts ex_detail.backtrace.join("\n")
				DbpediaLog.create(source_id:movie.id, source_type:thing_entity_type_id, info_type_id:info_type_id, status:'error', added_relationships:0, log_message:movie.name + ':  ' + ex_detail.to_s[0,(255-movie.name.length)])

			end



		end

	end



	def self.update_place_birthplace_info

		place_entity_type_id = EntityType.find_by_entity_type_desc('Place').id
		info_type_id = DbpediaInfo.get_or_create('Birthplace')

		# get the places that haven't had their "birthplace of" information retrieved yet
		places_to_update = Place.where('id not in (select source_id from populated_infos where source_type = ? and dbpedia_info_id = ? and is_populated = ?)', place_entity_type_id, info_type_id, true)

		places_to_update.each do |place|
			
			begin



				DbpediaLog.create(source_id:place.id, source_type:place_entity_type_id, info_type_id:info_type_id, status:'success', added_relationships:0, log_message:place.name)

			rescue

				#<TODO> add more information here
				DbpediaLog.create(source_id:place.id, source_type:place_entity_type_id, info_type_id:info_type_id, status:'error', added_relationships:0, log_message:place.name)

			end



		end

=begin
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

    consolodated_results.each do |con_res_id, con_res_vals|

	    tmp_format_date = nil
	    tmp_birthday_ymd = nil
	    unless con_res_vals['birthday'].blank?
	      split_date = con_res_vals['birthday'].split('/')
	      tmp_birthday_ymd = Ymddate.get_or_create(split_date[0], split_date[1], split_date[2])
	      tmp_format_date = con_res_vals['birthday']
	    end


	    tmp_new_person = Person.get_or_create(
        con_res_vals['name'],
        tmp_format_date,
        con_res_id,
        'dbpedia'
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
=end

	end

end