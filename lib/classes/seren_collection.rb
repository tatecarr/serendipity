class	SerenCollection

	attr_accessor :active_seren_objects, :inactive_seren_objects, :relations_to_find, :relations_found

	def initialize()

		@active_seren_objects = Array.new
		@inactive_seren_objects = Array.new

		@relations_to_find = Array.new
		@relations_found = Array.new
		
	end

	def get_moments(place)


		place_type_id = EntityType.get_entity_type_id('Place')

		place_unique = to_unique(place.id, place_type_id)

		rels = get_relevant_relations(place.id, place_type_id)


		rels.each do |rel|

			# obj = nil
			obj_unique = nil

			# if lookup was the source, we want to print target
			if(rel.source_id == place.id and rel.source_type == place_type_id)

				# obj = self.get_entity(rel.target_id, rel.target_type)
				obj_unique = to_unique(rel.target_id, rel.target_type)

			# else lookup was target, want to print the source
			else

				# obj = self.get_entity(rel.source_id, rel.source_type)
				obj_unique = to_unique(rel.source_id, rel.source_type)

			end

			@relations_to_find.push(obj_unique) unless @relations_to_find.include?(obj_unique)

			@active_seren_objects.push(SerenObj.new([place_unique, obj_unique], {obj_unique => rel.relationship_type}))

			# puts 'Relation:  ' + RelationshipType.find(rel.relationship_type).relationship_desc + ' ' + obj.to_s


		end



iteration_count = 0
		# get all the "last entities" for the objs

		# while relations_to_find.length > 0, take the first one (iterate over the relations_to_find)
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

					# if the new dupeobj array.size == 0, then move this seren_obj to the inactive_seren_obj array
					if sub_new_seren_objs.length == 0
					
						active_so.active = false
						indexes_to_inactivate.push(index)
# puts 'DEBUG--no results, setting active=FALSE:  ' + active_so.to_s

					# else we have new obj to add to the active_seren_objects
					# remove the previous obj--duplicate is returned on adding, which is "another level deep", don't need old one
					else
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
					@inactive_seren_objects.push(tmp_so) unless tmp_so.blank?

				# end
			end


		end



		moments = {}
		@inactive_seren_objects.each do |iso|
			len = iso.length
			if moments.keys.include?(len)
				moments[len] += [iso]
			else
				moments[len] = [iso]
			end
		end

		moments.keys.sort.each do |hl|
			puts 'Length of '+hl.to_s+':  '+moments[hl].length.to_s
		end

		return moments

		
	end



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