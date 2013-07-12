class	SerenCollection

	attr_accessor :active_seren_objects, :inactive_seren_objects, :relations_to_find, :relations_found

	def initialize()

		@active_seren_objects = Array.new
		@inactive_seren_objects = Array.new

		@relations_to_find = Array.new
		@relations_found = Array.new
		
	end

	def get_moments(entities, entity_type_id, options, moments_as_string=false)

		curr_user_person_id = options['curr_user_person_id']
		curr_person_unique = to_unique(curr_user_person_id, EntityType.get_entity_type_id('Person'))
		min_user_dist_from_origin = options['min_user_dist_from_origin']
		user_must_be_present = options['user_must_be_present']

		entity_array = []

		# This allows an array of entities, or a single entity to be passed.  If array, just assign to value
		# now we can iterate over the array for both cases because we'll have an array to work with
		if entities.class.to_s == 'Array'
			entity_array = entities
		else # type would be just a string/int/single value
			# else if a single entity is passed, add it to array
			entity_array.push(entities)
		end

		entity_array.each do |entity_id|

			entity_unique = to_unique(entity_id, entity_type_id)


			rels = get_relevant_relations(entity_id, entity_type_id)


			rels.each do |rel|

				# obj = nil
				obj_unique = nil

				# if lookup was the source, we want to print target
				if(rel.source_id == entity_id and rel.source_type == entity_type_id)

					# obj = self.get_entity(rel.target_id, rel.target_type)
					obj_unique = to_unique(rel.target_id, rel.target_type)

				# else lookup was target, want to print the source
				else

					# obj = self.get_entity(rel.source_id, rel.source_type)
					obj_unique = to_unique(rel.source_id, rel.source_type)

				end

				@relations_to_find.push(obj_unique) unless @relations_to_find.include?(obj_unique)

				@active_seren_objects.push(SerenObj.new([entity_unique, obj_unique], {obj_unique => rel.relationship_type}))

				# puts 'Relation:  ' + RelationshipType.find(rel.relationship_type).relationship_desc + ' ' + obj.to_s


			end

		end



iteration_count = 0
		# get all the "last entities" for the objs

		# while relations_to_find.length > 0, take the first one (iterate over the relations_to_find)

		# while(false)
		while(@relations_to_find.length > 0)


iteration_count += 1
# puts 'DEBUG--iteration count: ' + iteration_count.to_s
# puts 'DEBUG--relations_to_find length: ' + @relations_to_find.length.to_s
# puts @relations_to_find
# puts 'DEBUG--number of active seren_obj: ' + @active_seren_objects.length.to_s
			# remove the current relations_to_find element
			curr_unique = @relations_to_find.shift
			curr_entity = from_unque_to_id_type(curr_unique)
# puts 'DEBUG--curr_entity: ' + curr_entity.inspect

			# do query for new relationship records
			tmp_rels_unique_array = []
			tmp_rels = get_relevant_relations(curr_entity['entity_id'], curr_entity['entity_type'])
# puts 'DEBUG--tmp_rels' + tmp_rels.inspect
			tmp_rels.each do |rel|
				obj_unique = nil
				# if lookup was the source, we want to print target
				if(rel.source_id == curr_entity['entity_id'] and rel.source_type == curr_entity['entity_type'])
					obj_unique = to_unique(rel.target_id, rel.target_type)
				# else lookup was target, want to print the source
				else
					obj_unique = to_unique(rel.source_id, rel.source_type)
				end

				tmp_rels_unique_array.push({'entity' => obj_unique, 'relationship' => rel.relationship_type})
			end

			# keep track of "new" obj for the current "last entity" -- add after each iteration so doesn't get unnecessarily long when we know the last entity isn't going to match
			new_seren_objs = []


# puts 'DEBUG--seren_objs: ' + @active_seren_objects.inspect if @active_seren_objects.length < 4
			indexes_to_inactivate = []
			
			# iterate over the objs and find the ones who have the current "last entity"
			@active_seren_objects.each_with_index do |active_so, index|
				if active_so.active == true && active_so.last_entity == curr_unique
					
					# keep track of the new "dupe" objs = Array.new
					sub_new_seren_objs = []

					# iterate over the relations for will be added
					tmp_rels_unique_array.each do |each_unique|

						# add / duplicate these objs, adding them to the active objs array
						tmp_new_so = active_so.add_to_entities(each_unique['entity'], each_unique['relationship'])
						# if the last obj for the returned obj equals what was added, then we add this to the relations_to_find assuming not already there
						unless tmp_new_so.blank?
# puts 'DEBUG--Added SO: ' + tmp_new_so.inspect
							sub_new_seren_objs.push(tmp_new_so)
							@relations_to_find.push(tmp_new_so.last_entity) unless @relations_to_find.include?(tmp_new_so.last_entity)
						end
						# else it was already in the "seren chain" and do nothing

					end


					# BEGIN FILTERS for the SerenObj ----------------------------------------

					# check that the user is not within X links from SerenObj origin
					if(!min_user_dist_from_origin.blank?)

						if active_so.unique_entities.include?(curr_person_unique) && active_so.length < (min_user_dist_from_origin)
							active_so.active = false
							@active_seren_objects[index] = nil
						end

					end

					# END FILTERS for the SerenObj ----------------------------------------


					# if the new dupeobj array.size == 0, then move this seren_obj to the inactive_seren_obj array
					if active_so.active == true && (sub_new_seren_objs.length == 0) # || active_so.length > 3)
					
						move_to_inactive = true
						# if we enforce presence of current user, then check if they're included, if so, move to inactive array, otherwise delete
						if(!user_must_be_present.blank?)
							if user_must_be_present == true && !(active_so.unique_entities).include?(curr_person_unique)
								move_to_inactive = false
								active_so.active = false
								@active_seren_objects[index] = nil
							end
						end

						if move_to_inactive
							active_so.active = false
							indexes_to_inactivate.push(index)
						end
# puts 'DEBUG--no results, setting active=FALSE:  ' + active_so.to_s

					# else we have new obj to add to the active_seren_objects
					# remove the previous obj--duplicate is returned on adding, which is "another level deep", don't need old one
					elsif active_so.active == true
						@active_seren_objects[index] = nil # setting to nil, then compact! the array will remove
						new_seren_objs += sub_new_seren_objs
					end

				end

			end

			@active_seren_objects.compact! # removes nils which would be there if an obj was "duped"/another level was added
			@active_seren_objects += new_seren_objs # add any new seren objects that would have a new "last entity"

			# remove any SerenObj which are now inactive because no relations for their "last entity" can be added.
			indexes_to_inactivate.sort.reverse.each do |index|
# 				if so.active == false
# puts 'DEBUG--inactive getting moved:  ' + @active_seren_objects[index].to_s
					tmp_so = @active_seren_objects.delete_at(index)


					# Serendipities less than 5 entities in length are likely not interesting, deleting them straight up.
					if tmp_so.length >= 0 #5
						@inactive_seren_objects.push(tmp_so) unless tmp_so.blank?
					end

				# end
			end


		end


		moments = {}
	
		if moments_as_string

			descriptions = get_seren_object_descriptions(@inactive_seren_objects)

			@inactive_seren_objects.each do |iso|
			
				len = iso.length

				iso_string = build_seren_object_string(iso, descriptions)

				if moments.keys.include?(len)
					moments[len] += [iso_string]
				else
					moments[len] = [iso_string]
				end

			end

		else
			
			@inactive_seren_objects.each do |iso|
			
				len = iso.length

				if moments.keys.include?(len)
					moments[len] += [iso]
				else
					moments[len] = [iso]
				end

			end


		end

		# moments.keys.sort.each do |hl|
		# 	puts 'Length of '+hl.to_s+':  '+moments[hl].length.to_s
		# end

		return moments

		
	end

	def get_seren_object_descriptions(seren_objects)

		# puts 'Start-- get_seren_object_descriptions'

		person_type_id = EntityType.find_by_entity_type_desc('Person').id
		place_type_id = EntityType.find_by_entity_type_desc('Place').id
		thing_type_id = EntityType.find_by_entity_type_desc('Thing').id
		date_type_id = EntityType.find_by_entity_type_desc('Date').id

		to_lookup = {
			person_type_id => [],
			place_type_id => [],
			thing_type_id => [],
			date_type_id => [],
			'relationships' => []
		}

		seren_objects.each do |so|
			ents = so.unique_entities
			rels = so.entity_relationships

			ents.each do |ent|
				ent_info = from_unque_to_id_type(ent)
				to_lookup[ent_info['entity_type']].push(ent_info['entity_id']) unless to_lookup[ent_info['entity_type']].include?(ent_info['entity_id'])
			end

			rels.keys.each do |rel_key|
				to_lookup['relationships'].push(rels[rel_key]) unless to_lookup['relationships'].include?(rels[rel_key])
			end
		end

		people = {}
		ppl_res = Person.where(:id => to_lookup[person_type_id])
		ppl_res.each do |ppl|
			people[ppl.id] = ppl.to_s
		end

		places = {}
		place_res = Place.where(:id => to_lookup[place_type_id])
		place_res.each do |pl|
			places[pl.id] = pl.to_s
		end

		things = {}
		thing_res = Thing.where(:id => to_lookup[thing_type_id])
		thing_res.each do |th|
			things[th.id] = th.to_s
		end

		dates = {}
		date_res = Ymddate.where(:id => to_lookup[date_type_id])
		date_res.each do |dt|
			dates[dt.id] = dt.to_s
		end

		relationships = {}
		rels_res = RelationshipType.where(:id => to_lookup['relationships'])
		rels_res.each do |rl|
			relationships[rl.id] = rl.relationship_desc
		end

		descriptions = {
			person_type_id => people,
			place_type_id => places,
			thing_type_id => things,
			date_type_id => dates,
			'relationships' => relationships
		}

		# puts 'Person len:  ' + people.length.to_s, 'Place len:  ' + places.length.to_s, 'Thing len:  ' + things.length.to_s, 'Date len:  ' + dates.length.to_s, 'Rels len:  ' + relationships.length.to_s, ''

		# puts 'End-- get_seren_object_descriptions'

		return descriptions

	end

	def build_seren_object_string(seren_obj, descriptions)

		desc = ''

		seren_obj.unique_entities.each do |ent|

			entity_id = ent.slice(0,24).to_i(16)
			entity_type = ent.slice(24,8).to_i(16)

			rel_desc = ''
			relation = seren_obj.entity_relationships[ent]

			unless relation.blank?
				rel_desc = ' <-- ' + descriptions['relationships'][relation]
			end

			desc += rel_desc + ' ' + descriptions[entity_type][entity_id]

		end

		return desc
	end



	# def moments_to_strings(moments)

	# 	moments_string = {}

	# 	moments.each do |m|
	# 		len = m.length
	# 		if moments.keys.include?(len)
	# 			moments[len] += [iso]
	# 		else
	# 			moments[len] = [iso]
	# 		end
	# 	end

		
	# end


	# <TODO> Can probably speed this up
	def get_relevant_relations(entity_id, entity_type)

		rels = Relationship.where('(source_id = ? and source_type = ?) or (target_id = ? and target_type = ?)', entity_id, entity_type, entity_id, entity_type)

		return rels
		
	end


	def get_entity(entity_id, entity_type)

		type_desc = EntityType.find(entity_type).entity_type_desc

		case type_desc
			when 'Place'
				return Place.find(entity_id)
			when 'Person'
				return Person.find(entity_id)
			when 'Date'
				return Ymddate.find(entity_id)
			when 'Thing'
				return Thing.find(entity_id)
			else
				raise 'Unsupported entity type, should not be possible...'
		end
		
	end

	def to_unique(entity_id, entity_type)

		entity_id = entity_id.to_i
		entity_type = entity_type.to_i

		# 999 Septillion -- max 23 pad up to 24 places
		entity_id_str = entity_id.to_s(16)
		entity_id_str = pad_string(entity_id_str, 24)

		# 999 million -- max 8 pad up to 8 places
		entity_type_str = entity_type.to_s(16)
		entity_type_str = pad_string(entity_type_str, 8)

		return entity_id_str + entity_type_str
		
	end

	def from_unque_to_id_type(unique)

		entity_id = unique.slice(0,24).to_i(16)
		entity_type = unique.slice(24,8).to_i(16)

		return {'entity_id' => entity_id, 'entity_type' => entity_type}
		
	end

	def pad_string(str, pad_length)

		padded_str = str

		for i in 1..(pad_length-str.length)

			padded_str = '0' + padded_str

		end

		return padded_str
		
	end


end