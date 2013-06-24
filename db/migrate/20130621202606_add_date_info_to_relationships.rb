class AddDateInfoToRelationships < ActiveRecord::Migration
  def change
    add_column :relationships, :relationship_date, :date
    add_column :relationships, :ymddate_id, :integer
  end
end
