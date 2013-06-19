class DbpediaLog < ActiveRecord::Base
  attr_accessible :added_relationships, :info_type_id, :log_message, :source_id, :source_type, :status
end
