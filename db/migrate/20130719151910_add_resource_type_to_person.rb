class AddResourceTypeToPerson < ActiveRecord::Migration
  def change
  	add_column :people, :resource_type, :string
  end
end
