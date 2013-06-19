class DbpediaInfosController < ApplicationController
  # GET /dbpedia_infos
  # GET /dbpedia_infos.json
  def index
    @dbpedia_infos = DbpediaInfo.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @dbpedia_infos }
    end
  end

  # GET /dbpedia_infos/1
  # GET /dbpedia_infos/1.json
  def show
    @dbpedia_info = DbpediaInfo.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @dbpedia_info }
    end
  end

  # GET /dbpedia_infos/new
  # GET /dbpedia_infos/new.json
  def new
    @dbpedia_info = DbpediaInfo.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @dbpedia_info }
    end
  end

  # GET /dbpedia_infos/1/edit
  def edit
    @dbpedia_info = DbpediaInfo.find(params[:id])
  end

  # POST /dbpedia_infos
  # POST /dbpedia_infos.json
  def create
    @dbpedia_info = DbpediaInfo.new(params[:dbpedia_info])

    respond_to do |format|
      if @dbpedia_info.save
        format.html { redirect_to @dbpedia_info, notice: 'Dbpedia info was successfully created.' }
        format.json { render json: @dbpedia_info, status: :created, location: @dbpedia_info }
      else
        format.html { render action: "new" }
        format.json { render json: @dbpedia_info.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /dbpedia_infos/1
  # PUT /dbpedia_infos/1.json
  def update
    @dbpedia_info = DbpediaInfo.find(params[:id])

    respond_to do |format|
      if @dbpedia_info.update_attributes(params[:dbpedia_info])
        format.html { redirect_to @dbpedia_info, notice: 'Dbpedia info was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @dbpedia_info.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dbpedia_infos/1
  # DELETE /dbpedia_infos/1.json
  def destroy
    @dbpedia_info = DbpediaInfo.find(params[:id])
    @dbpedia_info.destroy

    respond_to do |format|
      format.html { redirect_to dbpedia_infos_url }
      format.json { head :no_content }
    end
  end
end
