class DropTablePersonFriends < ActiveRecord::Migration
  def up
  	drop_table :person_friends
  end

  def down
    create_table :person_friends do |t|
      t.integer :person_id
      t.integer :friend_uid
      t.string :friend_name

      t.timestamps
    end
  end
end
