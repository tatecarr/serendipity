class CreateEntityTypes < ActiveRecord::Migration
  def change
    create_table :entity_types do |t|
      t.string :entity_type_desc

      t.timestamps
    end
  end
end
