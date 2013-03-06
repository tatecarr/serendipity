class CreateTmpLatLongs < ActiveRecord::Migration
  def change
    create_table :tmp_lat_longs do |t|
      t.decimal :lat, :precision => 12, :scale => 4
      t.decimal :long, :precision => 12, :scale => 4
      t.string :type
      t.integer :keyval

      t.timestamps
    end
  end
end
