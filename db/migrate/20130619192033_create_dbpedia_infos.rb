class CreateDbpediaInfos < ActiveRecord::Migration
  def change
    create_table :dbpedia_infos do |t|
      t.string :info_type_desc
      t.integer :entity_type_id

      t.timestamps
    end
  end
end
