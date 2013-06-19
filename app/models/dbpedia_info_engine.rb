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
=end

	end

end