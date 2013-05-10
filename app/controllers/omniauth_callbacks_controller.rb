class OmniauthCallbacksController < Devise::OmniauthCallbacksController


	def facebook

    puts 'executing the callback'


    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.find_for_facebook_oauth(request.env["omniauth.auth"], current_user)


    # unless it's already populated - populate the ancillary person info tables with info from facebook if haven't already
    unless @user.person_populated

      @graph = Koala::Facebook::API.new(@user.access_token)

      #people table
      me = @graph.get_object('me')

      format_date = nil
      unless me['birthday'].blank?
        split_date = me['birthday'].split('/')
        format_date = split_date[2] + '/' + split_date[0] + '/' + split_date[1]
      end

      interested_in_list = me['interested_in'].join(',') if me['interested_in']

      new_person = Person.create(
        uid: @user.uid,
        name: me['name'],
        first_name: me['first_name'],
        last_name: me['last_name'],
        fb_link: me['link'],
        fb_username: me['username'],
        birthday: format_date,
        gender: me['gender'],
        interested_in: interested_in_list,
        political: me['political'],
        email: me['email'],
        timezone: me['timezone'],
        locale: me['locale'],
        person_populated: 1
      )



      # Current user hometown and current Location
      hometown = Place.get_fb_info_by_page_id(@user, me['hometown']['id'])
      hometown_lat = hometown['location']['latitude']
      hometown_long = hometown['location']['longitude']
      hometown_name = hometown['name']
      hometown_cat = hometown['category']

puts 'hometown-----',hometown_lat,hometown_long,hometown_name,hometown_cat,'hometown-----'

      hometown_record = Place.get_or_create(hometown_lat, hometown_long, hometown_name, hometown_cat)

      Relationship.create(
          source_id:new_person.id,
          source_type:EntityType.get_entity_type_id('Person'),
          target_id:hometown_record.id,
          target_type:EntityType.get_entity_type_id('Place'),
          relationship_type:RelationshipType.get_relationship_type_id('Hometown')
        )



      curr_location = Place.get_fb_info_by_page_id(@user, me['location']['id'])
      curr_location_record = Place.get_or_create(
          curr_location['location']['latitude'],
          curr_location['location']['longitude'],
          curr_location['name'],
          curr_location['category']
        )

      Relationship.create(
          source_id:new_person.id,
          source_type:EntityType.get_entity_type_id('Person'),
          target_id:curr_location_record.id,
          target_type:EntityType.get_entity_type_id('Place'),
          relationship_type:RelationshipType.get_relationship_type_id('CurrentLocation')
        )



      # PLACE
      # <TODO> need to get lat/lon for places that don't have it???


      #education
      ed = me['education']
      ed.each do |ed_elem|

        ed_details = @graph.get_object(ed_elem['school']['id'])
        ed_addr = ed_details['location']['city'] + ', ' + ed_details['location']['state'] + ', ' + ed_details['location']['country']

        lat_long = Place.geocode_location(ed_addr)

        tmp_place = Place.get_or_create(lat_long['lat'], lat_long['long'], ed_elem['school']['name'], ed_elem['type'])

        # tmp_ed = PersonEducation.create(
        #   person_id: new_person.id,
        #   education_id: ed_elem['school']['id'],
        #   name: ed_elem['school']['name'],
        #   type_desc: ed_elem['type']
        # )

        Relationship.create(
          source_id:new_person.id,
          source_type:EntityType.get_entity_type_id('Person'),
          target_id:tmp_place.id,
          target_type:EntityType.get_entity_type_id('Place'),
          relationship_type:RelationshipType.get_relationship_type_id(ed_elem['type'])
        )

      end


      #friends
      friends = @graph.get_connections('me', 'friends')
      friends.each do |f|
        PersonFriend.create(
          person_id: new_person.id,
          friend_uid: f['id'],
          friend_name: f['name']
        )
      end


      # "locations" are many different things in FB that have had location added e.g. Posts, Photos, Status
      locations = @graph.get_connections('me', 'locations')
      locations.each do |loc|

        loc_name = loc['place']['name']
        loc_lat = loc['place']['location']['latitude']
        loc_long = loc['place']['location']['longitude']
        loc_src = loc['type']

        loc_id = loc['place']['id']
        loc_details = @graph.get_object(loc_id)
        loc_type = loc_details['category']


        tmp_place = Place.get_or_create(loc_lat, loc_long, loc_name, loc_type)


        Relationship.create(
          source_id:new_person.id,
          source_type:EntityType.get_entity_type_id('Person'),
          target_id:tmp_place.id,
          target_type:EntityType.get_entity_type_id('Place'),
          relationship_type:RelationshipType.get_relationship_type_id(loc_src)
        )

      end



      # THINGS?  <TODO> Need to map the category to whether a PLACE or a THING?
      #likes
      likes = @graph.get_connections('me', 'likes')
      likes.each do |l|

        tmp_thing = Thing.get_or_create(l['name'], l['category'])

        # PersonLike.create(
        #   person_id: new_person.id,
        #   category: l['category'],
        #   name: l['name'],
        #   like_id: l['id']
        # )

        Relationship.create(
          source_id:new_person.id,
          source_type:EntityType.get_entity_type_id('Person'),
          target_id:tmp_thing.id,
          target_type:EntityType.get_entity_type_id('Thing'),
          relationship_type:RelationshipType.get_relationship_type_id(l['category'])
        )

      end

      @user.person_populated = 1
      @user.save


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
