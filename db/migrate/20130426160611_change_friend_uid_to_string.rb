class ChangeFriendUidToString < ActiveRecord::Migration
  def up
  	remove_column :person_friends, :friend_uid
    add_column :person_friends, :friend_uid, :string
  end

  def down
  	remove_column :person_friends, :friend_uid
    add_column :person_friends, :friend_uid, :integer
  end
end
