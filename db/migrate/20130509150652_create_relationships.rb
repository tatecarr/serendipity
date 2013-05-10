class CreateRelationships < ActiveRecord::Migration
  def change
    create_table :relationships do |t|
      t.integer :source_id
      t.integer :source_type
      t.integer :target_id
      t.integer :target_type
      t.integer :relationship_type

      t.timestamps
    end
  end
end
