class EntityType < ActiveRecord::Base
  attr_accessible :entity_type_desc

  # return the entity type ID for the given type -- record may be created first if does not exist
  def self.get_entity_type_id(type)

  	entity_type = EntityType.find_by_entity_type_desc(type)

  	if entity_type.nil?
  		entity_type = EntityType.create(entity_type_desc:type)
  	end

  	return entity_type.id

  end

end
