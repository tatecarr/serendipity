class CreatePersonEducations < ActiveRecord::Migration
  def change
    create_table :person_educations do |t|
      t.integer :person_id
      t.integer :education_id
      t.string :name
      t.string :type_desc

      t.timestamps
    end
  end
end
