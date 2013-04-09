class DropTypeFromPlaces < ActiveRecord::Migration
  def up
  	rename_column :places, :type, :type_desc
  end

  def down
  	rename_column :places, :type_desc, :type
  end
end
