class ChangeUidToString < ActiveRecord::Migration
  def up
  	remove_column :people, :uid
    add_column :people, :uid, :string
  end

  def down
  	remove_column :people, :uid
    add_column :people, :uid, :integer
  end
end