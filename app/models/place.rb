class Place < ActiveRecord::Base
  attr_accessible :lat, :long, :name, :tags, :type_desc

  def self.find_by_lat_lng(lat, lng, search_radius='100')


  	sql_string = 'SELECT * FROM PLACES WHERE SQRT((69.1 * ('+lat+' - lat)) * (69.1 * ('+lat+' - lat)) + (69.1 * ('+lng+' - long) * COS(lat/57.3)) * (69.1 * ('+lng+' - long) * cos(lat/57.3))) <= '+search_radius

  	places = Place.find_by_sql(sql_string, [])

  	return places
  	
  end

  def self.get_or_create(lat, long, name, type_desc)

  	place = Place.find_by_name(name)

  	if place.nil?
  		place = Place.create(lat:lat, long:long, name:name, type_desc:type_desc)
  	end

  	return place

  end


  def self.get_fb_info_by_page_id(current_user, fb_id)

  	graph = Koala::Facebook::API.new(current_user.access_token)

  	loc = graph.get_object(fb_id)

  	# lat_long = Hash.new
  	# begin
  	# 	lat_long['lat'] = loc['location']['latitude']
  	# 	lat_long['long'] = loc['location']['longitude']
  	# rescue
  	# 	lat_long = nil
  	# end

  	return loc # lat_long

  end


  def self.geocode_location(address_string)

  	esc_address_string = CGI::escape(address_string)
  	url = 'http://maps.googleapis.com/maps/api/geocode/json?address=' + esc_address_string + '&sensor=false'

  	resp = HTTParty.get(url)
    return_json = nil

    if resp.code == 200

      # parse and then render to json because was including newlines and whitespace from google
      geo_json = JSON.parse(resp.body)

      return_json = {'lat' => geo_json['results'][0]['geometry']['location']['lat'], 'long' => geo_json['results'][0]['geometry']['location']['lng']}

    else
      raise 'Error getting places from google web service'
    end

    return return_json
  	
  end

end
