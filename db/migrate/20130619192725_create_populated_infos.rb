class CreatePopulatedInfos < ActiveRecord::Migration
  def change
    create_table :populated_infos do |t|
      t.integer :source_id
      t.integer :source_type
      t.integer :dbpedia_info_id
      t.boolean :is_populated

      t.timestamps
    end
  end
end
