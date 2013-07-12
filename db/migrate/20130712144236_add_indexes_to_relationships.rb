class AddIndexesToRelationships < ActiveRecord::Migration
  def change
  	add_index :relationships, :id
  	add_index :relationships, :source_id
		add_index :relationships, :source_type
		add_index :relationships, :target_id
		add_index :relationships, :target_type
		add_index :relationships, :relationship_type
		add_index :relationships, :ymddate_id
  end
end
