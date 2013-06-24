class DropTablePersonEducations < ActiveRecord::Migration
  def up
  	drop_table :person_educations
  end

  def down
  	create_table :person_educations do |t|
      t.integer :person_id
      t.integer :education_id
      t.string :name
      t.string :type_desc

      t.timestamps
    end
  end
end
