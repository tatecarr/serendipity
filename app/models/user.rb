class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:facebook]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :provider, :uid, :access_token
  # attr_accessible :title, :body

  def person
  	Person.find_by_uid(self.uid)
  end


  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)

  	puts auth.inspect

  	puts 'Token----',auth.token,auth.credentials.token,'-----Token'

	  user = User.where(:provider => auth.provider, :uid => auth.uid).first
	  unless user

	  	# name:auth.extra.raw_info.name,
	    
	    user = User.create(
	                         provider:auth.provider,
	                         uid:auth.uid,
	                         access_token:auth.credentials.token,
	                         email:auth.info.email,
	                         password:Devise.friendly_token[0,20]
	                         )

	  end
	  user

	end


end
