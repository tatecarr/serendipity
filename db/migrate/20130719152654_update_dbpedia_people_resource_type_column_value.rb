class UpdateDbpediaPeopleResourceTypeColumnValue < ActiveRecord::Migration
  def up
  	Person.where('resource_id is not null').update_all(:resource_type => 'dbpedia')
  end

  def down
  end
end
