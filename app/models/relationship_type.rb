class RelationshipType < ActiveRecord::Base
  attr_accessible :relationship_desc, :relation_category_id

  # return the entity type ID for the given type -- record may be created first if does not exist
  def self.get_relationship_type_id(type)

  	relationship_type = RelationshipType.find_by_relationship_desc(type)

  	if relationship_type.nil?
  		relationship_type = RelationshipType.create(relationship_desc:type)
  	end

  	return relationship_type.id

  end
  
end
