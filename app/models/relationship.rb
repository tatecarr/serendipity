class Relationship < ActiveRecord::Base
  attr_accessible :relationship_type, :source_id, :source_type, :target_id, :target_type, :relationship_date, :ymddate_id


  def self.create_ignore_dupe(source_id, source_type, target_id, target_type, relationship_type, relationship_date, ymddate_id)

  	dupe = Relationship.where(:source_id => source_id, :source_type => source_type, :target_id => target_id, :target_type => target_type, :relationship_type => relationship_type, :ymddate_id => ymddate_id)

  	unless dupe.count > 0

	  	Relationship.create(
	          source_id:source_id,
	          source_type:source_type,
	          target_id:target_id,
	          target_type:target_type,
	          relationship_type:relationship_type,
	          relationship_date:relationship_date,
	          ymddate_id:ymddate_id
	        )
	  end
  	
  end

end
