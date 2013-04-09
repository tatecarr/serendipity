class Place < ActiveRecord::Base
  attr_accessible :lat, :long, :name, :tags, :type_desc

  def self.find_by_lat_lng(lat, lng, search_radius='100')


  	sql_string = 'SELECT * FROM PLACES WHERE SQRT((69.1 * ('+lat+' - lat)) * (69.1 * ('+lat+' - lat)) + (69.1 * ('+lng+' - long) * COS(lat/57.3)) * (69.1 * ('+lng+' - long) * cos(lat/57.3))) <= '+search_radius

  	places = Place.find_by_sql(sql_string, [])

  	return places
  	
  end
end
