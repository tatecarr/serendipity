class ChangeLikeIdToString < ActiveRecord::Migration
  def up
  	remove_column :person_likes, :like_id
  	add_column :person_likes, :like_id, :string
  end

  def down
  	remove_column :person_likes, :like_id
  	add_column :person_likes, :like_id, :integer
  end
end
