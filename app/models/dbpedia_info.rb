class DbpediaInfo < ActiveRecord::Base
	belongs_to :entity_type
  attr_accessible :entity_type_id, :info_type_desc

  def self.get_or_create(type_desc)
  	dbpedia_info = DbpediaInfo.find_by_info_type_desc(type_desc)
  	
  	if dbpedia_info.blank?
  		dbpedia_info = DbpediaInfo.create(info_type_desc:type_desc)
  	end

  	return dbpedia_info.id
  end

end
