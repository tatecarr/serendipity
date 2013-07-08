class SerenObj

	attr_accessor :unique_entities, :entity_relationships, :last_entity, :active
	
	def initialize(entity_array, entity_relationships)

		@unique_entities = entity_array # [first_entity, second_entity]

		@entity_relationships = entity_relationships # {second_entity => relationship}

		@last_entity = entity_array.last

		@active = true


		# <TODO> They are going to duplicate?  It's really a growing tree of relationships, not a static list of relationships that just grows
		# then you'd be restricted to a list in length equal to the number of results from the first query

		
	end

	def length

		return @unique_entities.length
		
	end

	def to_s

		desc = ''

		@unique_entities.each do |ent|

			entity_id = ent.slice(0,24).to_i(16)
			entity_type = ent.slice(24,8).to_i(16)

			entity = get_entity(entity_id, entity_type)

			rel_desc = ''
			relation = @entity_relationships[ent]
			unless relation.blank?
				rel_desc = ' <-- ' + RelationshipType.find(relation).relationship_desc
			end

			desc += rel_desc + ' ' + entity.to_s

		end

		return desc
	end

	def add_to_entities(entity, relationship)

		unless @unique_entities.include?(entity)

			tmp_unique_entities = @unique_entities.dup
			tmp_unique_entities.push(entity)

			tmp_entity_relationships = @entity_relationships.dup
			tmp_entity_relationships[entity] = relationship

			return SerenObj.new(tmp_unique_entities, tmp_entity_relationships)

		else
			return nil
		end
		
	end

	def print_entities()

		puts @unique_entities
		
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


end