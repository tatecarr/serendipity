class OmniauthCallbacksController < Devise::OmniauthCallbacksController


	def facebook

    puts 'executing the callback'


    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.find_for_facebook_oauth(request.env["omniauth.auth"], current_user)

    user_access_token = @user.access_token

    # unless it's already populated - populate the ancillary person info tables with info from facebook if haven't already
    unless @user.person_populated

      User.populate_fb_person_record(@user)

    end


    if @user.persisted?

      puts '- It is persisted'

      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
    else

      puts '- NOT persisted'

      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end


end
