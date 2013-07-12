class PlacesController < ApplicationController
  # GET /places
  # GET /places.json
  def index

    @graph = Koala::Facebook::API.new(current_user.access_token)

    @places = Place.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @places }
    end
  end

  # GET /places/1
  # GET /places/1.json
  def show
    @place = Place.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @place }
    end
  end

  # GET /places/new
  # GET /places/new.json
  def new
    @place = Place.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @place }
    end
  end

  # GET /places/1/edit
  def edit
    @place = Place.find(params[:id])
  end

  # POST /places
  # POST /places.json
  def create
    @place = Place.new(params[:place])

    respond_to do |format|
      if @place.save
        format.html { redirect_to @place, notice: 'Place was successfully created.' }
        format.json { render json: @place, status: :created, location: @place }
      else
        format.html { render action: "new" }
        format.json { render json: @place.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /places/1
  # PUT /places/1.json
  def update
    @place = Place.find(params[:id])

    respond_to do |format|
      if @place.update_attributes(params[:place])
        format.html { redirect_to @place, notice: 'Place was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @place.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /places/1
  # DELETE /places/1.json
  def destroy
    @place = Place.find(params[:id])
    @place.destroy

    respond_to do |format|
      format.html { redirect_to places_url }
      format.json { head :no_content }
    end
  end

  def get_nearby_places

    lat = params[:lat]
    lng = params[:lng]
    search_radius = params[:search_radius]

    @places = Place.find_by_lat_lng(lat, lng, search_radius)

    # puts 'LatLng-----',lat,lng,'-----LatLng'

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @places }
    end
  end


  def get_google_nearby_places

    google_api_key = 'AIzaSyDAv-dHqblICmyP7hX8PHzvfmKyKsa1r2U'

    keyword = (params[:keyword]).blank? ? '' : '&keyword='+params[:keyword]

    url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?'
    url_params = 'key='+google_api_key+'&location='+params[:location]+'&radius='+params[:radius]+'&sensor='+params[:sensor]+keyword
    # params = 'key=AIzaSyDAv-dHqblICmyP7hX8PHzvfmKyKsa1r2U&location=35.2269%2C-80.8433&radius=1000&sensor=false&keyword=fast'


    resp = HTTParty.get(url+url_params)
    return_json = nil

    if resp.code == 200

      # parse and then render to json because was including newlines and whitespace from google
      return_json = JSON.parse(resp.body)

    else
      raise 'Error getting places from google web service'
    end

    respond_to do |format|
      # format.html # index.html.erb
      format.json { render json: return_json }
    end

  end


  def get_nearby_connections

    return_json = {}
    moments = nil

    lat = params[:lat]
    lng = params[:lng]
    search_radius = params[:search_radius]

    places = Place.find_by_lat_lng(lat, lng, search_radius) if !lat.blank? && !lng.blank? && !search_radius.blank?

    unless places.blank?
      
      places_ids = places.collect { |place| place.id }

      sc = SerenCollection.new

      moments = sc.get_moments(places_ids, EntityType.find_by_entity_type_desc('Place').id, {'user_must_be_present' => true, 'curr_user_person_id' => current_user.person.id, 'min_user_dist_from_origin' => 4}, false)

    end

    if moments.blank?
      sleep 1
    else
      return_json = moments
    end


    respond_to do |format|
      format.json { render json: return_json }
    end
    
  end

end
