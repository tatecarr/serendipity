class PersonFriend < ActiveRecord::Base
  attr_accessible :friend_name, :friend_uid, :person_id
end
