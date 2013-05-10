class AddPersonPopulatedToUser < ActiveRecord::Migration
  def change
    add_column :users, :person_populated, :boolean
  end
end
