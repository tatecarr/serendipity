class Person < ActiveRecord::Base
  attr_accessible :birthday, :email, :fb_link, :fb_username, :first_name, :gender, :interested_in, :last_name, :locale, :name, :political, :timezone, :uid
end
