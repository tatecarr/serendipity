class AddRelationshipCategoryIdToDbpediaInfos < ActiveRecord::Migration
  def change
    add_column :dbpedia_infos, :relation_category_id, :integer
  end
end
