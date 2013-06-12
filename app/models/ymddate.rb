class Ymddate < ActiveRecord::Base
  attr_accessible :day, :month, :year

  def self.get_or_create(year, month, day)

  	ymd = Ymddate.where(:year => year.to_i, :month => month.to_i, :day => day.to_i)
  	unless ymd.blank?
  		ymd = ymd[0] # it's a relation when using .where -- so get the first result if there is one
  	end

  	if ymd.blank?
  		ymd = Ymddate.create(year:year, month:month, day:day)
  	end

  	return ymd

  end

end