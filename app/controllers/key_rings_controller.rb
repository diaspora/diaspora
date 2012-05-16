class KeyRingsController < ApplicationController
  # GET /key_rings
  # GET /key_rings.json
  def index
    @key_rings = KeyRing.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @key_rings }
    end
  end

  # GET /key_rings/1
  # GET /key_rings/1.json
  def show
    @key_rings = Contact.where(:id => params[:contact_ids].split(',')).map! do |contact|
      { :contact => contact.id, :key_ring => contact.person.key_ring }
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @key_rings }
    end
  end

  # GET /key_rings/new
  # GET /key_rings/new.json
  def new
    @key_ring = KeyRing.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @key_ring }
    end
  end

  # GET /key_rings/1/edit
  def edit
    @key_ring = KeyRing.find(params[:id])
  end

  # POST /key_rings
  # POST /key_rings.json
  def create
    @key_ring = KeyRing.new
    @key_ring.secured_encryption_key = params[:secured_encryption_key]
    @key_ring.public_encryption_key = params[:public_encryption_key]
    @key_ring.secured_signing_key = params[:secured_signing_key]
    @key_ring.public_verification_key = params[:public_verification_key]
    @key_ring.person = Person.find_from_guid_or_username(:id => params[:guid])

    respond_to do |format|
      if @key_ring.save
        format.js { }
      else
        format.html { render action: "new" }
        format.json { render json: @key_ring.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /key_rings/1
  # PUT /key_rings/1.json
  def update
    @key_ring = KeyRing.find(params[:id])

    respond_to do |format|
      if @key_ring.update_attributes(params[:key_ring])
        format.html { redirect_to @key_ring, notice: 'Key ring was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @key_ring.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /key_rings/1
  # DELETE /key_rings/1.json
  def destroy
    @key_ring = KeyRing.find(params[:id])
    @key_ring.destroy

    respond_to do |format|
      format.html { redirect_to key_rings_url }
      format.json { head :ok }
    end
  end
end
