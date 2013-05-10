class AddPersonPopulatedToPerson < ActiveRecord::Migration
  def change
    add_column :people, :person_populated, :boolean
  end
end
