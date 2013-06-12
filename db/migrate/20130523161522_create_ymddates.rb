class CreateYmddates < ActiveRecord::Migration
  def change
    create_table :ymddates do |t|
      t.integer :year
      t.integer :month
      t.integer :day

      t.timestamps
    end
  end
end
