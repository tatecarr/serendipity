class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_user!
  before_filter :set_user_picture

  
  def set_user_picture
  	if current_user && current_user.uid
  	 	@picture_url = 'https://graph.facebook.com/'+current_user.uid+'/picture'
  	 else
  	 	@picture_url = 'http://www.clker.com/cliparts/5/9/4/c/12198090531909861341man%20silhouette.svg.med.png'
  	 end
  end
  

  


end
