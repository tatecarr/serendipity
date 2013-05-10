class CreateRelationshipTypes < ActiveRecord::Migration
  def change
    create_table :relationship_types do |t|
      t.string :relationship_desc

      t.timestamps
    end
  end
end
