class CreateRelationshipCategories < ActiveRecord::Migration
  def change
    create_table :relationship_categories do |t|
      t.string :description

      t.timestamps
    end
  end
end
