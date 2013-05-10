class PersonLike < ActiveRecord::Base
  attr_accessible :category, :like_id, :name, :person_id
end
