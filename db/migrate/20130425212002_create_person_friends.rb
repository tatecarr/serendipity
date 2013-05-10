class CreatePersonFriends < ActiveRecord::Migration
  def change
    create_table :person_friends do |t|
      t.integer :person_id
      t.integer :friend_uid
      t.string :friend_name

      t.timestamps
    end
  end
end
