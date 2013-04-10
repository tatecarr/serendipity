class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_user!
  before_filter :set_user_picture

  
  def set_user_picture
  	@picture_url = 'https://graph.facebook.com/'+current_user.uid+'/picture'
  end
  
end
