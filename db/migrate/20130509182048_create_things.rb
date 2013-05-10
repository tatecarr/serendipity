class CreateThings < ActiveRecord::Migration
  def change
    create_table :things do |t|
      t.string :name
      t.string :type_desc

      t.timestamps
    end
  end
end
