class CreatePlaces < ActiveRecord::Migration
  def change
    create_table :places do |t|
      t.decimal :lat, :precision => 12, :scale => 4
      t.decimal :long, :precision => 12, :scale => 4
      t.string :name
      t.string :type
      t.string :tags

      t.timestamps
    end
  end
end
