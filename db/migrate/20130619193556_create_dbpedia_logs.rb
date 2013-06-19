class CreateDbpediaLogs < ActiveRecord::Migration
  def change
    create_table :dbpedia_logs do |t|
      t.integer :source_id
      t.integer :source_type
      t.integer :info_type_id
      t.string :status
      t.integer :added_relationships
      t.string :log_message

      t.timestamps
    end
  end
end
