class Relationship < ActiveRecord::Base
  attr_accessible :relationship_type, :source_id, :source_type, :target_id, :target_type
end
