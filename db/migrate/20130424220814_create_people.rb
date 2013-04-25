class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.integer :uid
      t.string :name
      t.string :first_name
      t.string :last_name
      t.string :fb_link
      t.string :fb_username
      t.date :birthday
      t.string :gender
      t.string :interested_in
      t.string :political
      t.string :email
      t.integer :timezone
      t.string :locale

      t.timestamps
    end
  end
end
