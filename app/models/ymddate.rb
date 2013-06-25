class Ymddate < ActiveRecord::Base
  attr_accessible :day, :month, :year

  def to_s

    to_return = self.year.to_s + '-' + self.month.to_s + '-' + self.day.to_s
    
  end

  def self.get_or_create(year, month, day)

  	ymd = Ymddate.where(:year => year.to_i, :month => month.to_i, :day => day.to_i)
  	unless ymd.blank?
      logger.debug 'YMD is not blank, taking first row'
  		ymd = ymd[0] # it's a relation when using .where -- so get the first result if there is one
  	end

  	if ymd.blank?
      logger.debug 'YMD is blank, should be creating...'
  		ymd = Ymddate.create(year:year, month:month, day:day)
  	end

  	return ymd

  end

end
