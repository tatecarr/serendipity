class PopulatedInfo < ActiveRecord::Base
  attr_accessible :dbpedia_info_id, :is_populated, :source_id, :source_type
end
