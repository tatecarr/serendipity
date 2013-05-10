class Person < ActiveRecord::Base
	has_many :person_educations
	has_many :person_friends
	has_many :person_likes

  attr_accessible :birthday, :email, :fb_link, :fb_username, :first_name, :gender, :interested_in, :last_name, :locale, :name, :political, :timezone, :uid, :person_populated
end
