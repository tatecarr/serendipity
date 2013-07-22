class Person < ActiveRecord::Base

  attr_accessible :birthday, :email, :fb_link, :fb_username, :first_name, :gender, :interested_in, :last_name, :locale, :name, :political, :timezone, :uid, :person_populated, :resource_id, :resource_type

  validates_uniqueness_of :uid, :allow_nil => true, :allow_blank => true

  def to_s

    return self.name
    
  end

  def self.get_or_create(name, birthday, resource_id, resource_type)

  	tmp_person = Person.where(:resource_id => resource_id.to_s, :resource_type => resource_type.to_s)

  	if tmp_person.blank?
  		logger.debug 'Person was not found, should be creating...'
  		tmp_person = Person.create(:name => name, :birthday => birthday, :resource_id => resource_id, :resource_type => resource_type)
    else
      # it's a ActiveRecord Relation (like an array) - likely of just 1 record, but need to get the 1 record to return rather than the "Relation"
      tmp_person = tmp_person[0]
  	end

  	return tmp_person
  	
  end
end
