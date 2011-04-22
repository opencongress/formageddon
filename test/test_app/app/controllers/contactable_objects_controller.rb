class ContactableObjectsController < ApplicationController
  # GET /contactable_objects
  # GET /contactable_objects.xml
  def index
    @contactable_objects = ContactableObject.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @contactable_objects }
    end
  end

  # GET /contactable_objects/1
  # GET /contactable_objects/1.xml
  def show
    @contactable_object = ContactableObject.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @contactable_object }
    end
  end

  # GET /contactable_objects/new
  # GET /contactable_objects/new.xml
  def new
    @contactable_object = ContactableObject.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @contactable_object }
    end
  end

  # GET /contactable_objects/1/edit
  def edit
    @contactable_object = ContactableObject.find(params[:id])
  end

  # POST /contactable_objects
  # POST /contactable_objects.xml
  def create
    @contactable_object = ContactableObject.new(params[:contactable_object])

    respond_to do |format|
      if @contactable_object.save
        format.html { redirect_to(@contactable_object, :notice => 'Contactable object was successfully created.') }
        format.xml  { render :xml => @contactable_object, :status => :created, :location => @contactable_object }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @contactable_object.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /contactable_objects/1
  # PUT /contactable_objects/1.xml
  def update
    @contactable_object = ContactableObject.find(params[:id])

    respond_to do |format|
      if @contactable_object.update_attributes(params[:contactable_object])
        format.html { redirect_to(@contactable_object, :notice => 'Contactable object was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @contactable_object.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /contactable_objects/1
  # DELETE /contactable_objects/1.xml
  def destroy
    @contactable_object = ContactableObject.find(params[:id])
    @contactable_object.destroy

    respond_to do |format|
      format.html { redirect_to(contactable_objects_url) }
      format.xml  { head :ok }
    end
  end
end
