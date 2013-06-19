class DbpediaLogsController < ApplicationController
  # GET /dbpedia_logs
  # GET /dbpedia_logs.json
  def index
    @dbpedia_logs = DbpediaLog.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @dbpedia_logs }
    end
  end

  # GET /dbpedia_logs/1
  # GET /dbpedia_logs/1.json
  def show
    @dbpedia_log = DbpediaLog.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @dbpedia_log }
    end
  end

  # GET /dbpedia_logs/new
  # GET /dbpedia_logs/new.json
  def new
    @dbpedia_log = DbpediaLog.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @dbpedia_log }
    end
  end

  # GET /dbpedia_logs/1/edit
  def edit
    @dbpedia_log = DbpediaLog.find(params[:id])
  end

  # POST /dbpedia_logs
  # POST /dbpedia_logs.json
  def create
    @dbpedia_log = DbpediaLog.new(params[:dbpedia_log])

    respond_to do |format|
      if @dbpedia_log.save
        format.html { redirect_to @dbpedia_log, notice: 'Dbpedia log was successfully created.' }
        format.json { render json: @dbpedia_log, status: :created, location: @dbpedia_log }
      else
        format.html { render action: "new" }
        format.json { render json: @dbpedia_log.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /dbpedia_logs/1
  # PUT /dbpedia_logs/1.json
  def update
    @dbpedia_log = DbpediaLog.find(params[:id])

    respond_to do |format|
      if @dbpedia_log.update_attributes(params[:dbpedia_log])
        format.html { redirect_to @dbpedia_log, notice: 'Dbpedia log was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @dbpedia_log.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dbpedia_logs/1
  # DELETE /dbpedia_logs/1.json
  def destroy
    @dbpedia_log = DbpediaLog.find(params[:id])
    @dbpedia_log.destroy

    respond_to do |format|
      format.html { redirect_to dbpedia_logs_url }
      format.json { head :no_content }
    end
  end
end
