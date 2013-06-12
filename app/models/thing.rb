class Thing < ActiveRecord::Base
  attr_accessible :name, :type_desc

  def self.get_or_create(name, type_desc)

  	thing = Thing.find_by_name(name)

  	if thing.blank?
  		thing = Thing.create(name:name, type_desc:type_desc)
  	end

  	return thing

  end
end
