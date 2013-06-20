class MoveRelationshipCategoriesIdFromDbpToRelType < ActiveRecord::Migration
  def up
  	add_column :relationship_types, :relation_category_id, :integer
  	remove_column :dbpedia_infos, :relation_category_id
  end

  def down
    add_column :dbpedia_infos, :relation_category_id, :integer
    remove_column :relationship_types, :relation_category_id
  end
end
