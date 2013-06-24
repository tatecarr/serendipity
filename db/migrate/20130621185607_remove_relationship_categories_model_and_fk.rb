class RemoveRelationshipCategoriesModelAndFk < ActiveRecord::Migration
  def up
  	remove_column :relationship_types, :relation_category_id
  	drop_table :relationship_categories
  end

  def down
    create_table :relationship_categories do |t|
      t.string :description

      t.timestamps
    end
    add_column :relationship_types, :relation_category_id, :integer
  end
end
