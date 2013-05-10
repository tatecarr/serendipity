class ChangeEducationIdToString < ActiveRecord::Migration
  def up
  	remove_column :person_educations, :education_id
    add_column :person_educations, :education_id, :string
  end

  def down
  	remove_column :person_educations, :education_id
    add_column :person_educations, :education_id, :integer
  end
end
