class CreatePersonLikes < ActiveRecord::Migration
  def change
    create_table :person_likes do |t|
      t.integer :person_id
      t.string :category
      t.string :name
      t.integer :like_id

      t.timestamps
    end
  end
end
