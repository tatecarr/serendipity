class TmpLatLongsController < ApplicationController
  # GET /tmp_lat_longs
  # GET /tmp_lat_longs.json
  def index
    @tmp_lat_longs = TmpLatLong.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tmp_lat_longs }
    end
  end

  # GET /tmp_lat_longs/1
  # GET /tmp_lat_longs/1.json
  def show
    @tmp_lat_long = TmpLatLong.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @tmp_lat_long }
    end
  end

  # GET /tmp_lat_longs/new
  # GET /tmp_lat_longs/new.json
  def new
    @tmp_lat_long = TmpLatLong.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @tmp_lat_long }
    end
  end

  # GET /tmp_lat_longs/1/edit
  def edit
    @tmp_lat_long = TmpLatLong.find(params[:id])
  end

  # POST /tmp_lat_longs
  # POST /tmp_lat_longs.json
  def create
    @tmp_lat_long = TmpLatLong.new(params[:tmp_lat_long])

    respond_to do |format|
      if @tmp_lat_long.save
        format.html { redirect_to @tmp_lat_long, notice: 'Tmp lat long was successfully created.' }
        format.json { render json: @tmp_lat_long, status: :created, location: @tmp_lat_long }
      else
        format.html { render action: "new" }
        format.json { render json: @tmp_lat_long.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tmp_lat_longs/1
  # PUT /tmp_lat_longs/1.json
  def update
    @tmp_lat_long = TmpLatLong.find(params[:id])

    respond_to do |format|
      if @tmp_lat_long.update_attributes(params[:tmp_lat_long])
        format.html { redirect_to @tmp_lat_long, notice: 'Tmp lat long was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @tmp_lat_long.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tmp_lat_longs/1
  # DELETE /tmp_lat_longs/1.json
  def destroy
    @tmp_lat_long = TmpLatLong.find(params[:id])
    @tmp_lat_long.destroy

    respond_to do |format|
      format.html { redirect_to tmp_lat_longs_url }
      format.json { head :no_content }
    end
  end
end
