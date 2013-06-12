class AddResourceIdToPerson < ActiveRecord::Migration
  def change
    add_column :people, :resource_id, :string
  end
end
