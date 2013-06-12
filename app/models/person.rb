class Person < ActiveRecord::Base
	has_many :person_educations
	has_many :person_friends
	has_many :person_likes

  attr_accessible :birthday, :email, :fb_link, :fb_username, :first_name, :gender, :interested_in, :last_name, :locale, :name, :political, :timezone, :uid, :person_populated, :resource_id

  def self.get_or_create(name, birthday, resource_id)

  	tmp_person = Person.find_by_resource_id(resource_id)

  	if tmp_person.blank?
  		tmp_person = Person.create(:name => name, :birthday => birthday, :resource_id => resource_id)
  	end

  	return tmp_person
  	
  end
end
