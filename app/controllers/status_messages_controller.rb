#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class StatusMessagesController < ApplicationController
  helper :comments, :likes
  before_filter :authenticate_user!

  respond_to :html
  respond_to :mobile
  respond_to :json, :only => :show

  def new
    @person = Person.find(params[:person_id])
    @aspect = :profile
    @contact = current_user.contact_for(@person)
    @aspects_with_person = []
    if @contact
      @aspects_with_person = @contact.aspects
      @aspect_ids = @aspects_with_person.map(&:id)
      @contacts_of_contact = @contact.contacts

      render :layout => nil
    else
      redirect_to :back
    end
  end

  def bookmarklet
    @aspects = current_user.aspects
    @selected_contacts = @aspects.map { |aspect| aspect.contacts }.flatten.uniq
    @aspect_ids = @aspects.map{|x| x.id}
    render :layout => nil
  end

  def create
    params[:status_message][:aspect_ids] = params[:aspect_ids]

    photos = Photo.where(:id => [*params[:photos]], :diaspora_handle => current_user.person.diaspora_handle)

    public_flag = params[:status_message][:public]
    public_flag.to_s.match(/(true)|(on)/) ? public_flag = true : public_flag = false
    params[:status_message][:public] = public_flag

    @status_message = current_user.build_post(:status_message, params[:status_message])
    aspects = current_user.aspects_from_ids(params[:aspect_ids])

    if !photos.empty?
      @status_message.photos << photos
    end
    if @status_message.save
      Rails.logger.info("event=create type=status_message chars=#{params[:status_message][:text].length}")

      current_user.add_to_streams(@status_message, aspects)
      receiving_services = params[:services].map{|s| current_user.services.where(
                                  :type => "Services::"+s.titleize).first} if params[:services]
      current_user.dispatch_post(@status_message, :url => post_url(@status_message), :services => receiving_services)
      if !photos.empty?
        for photo in photos
          was_pending = photo.pending
          if was_pending
            current_user.add_to_streams(photo, aspects)
            current_user.dispatch_post(photo)
          end
        end
        photos.update_all(:pending => false, :public => public_flag)
      end

      if request.env['HTTP_REFERER'].include?("people")
        flash[:notice] = t('status_messages.create.success', :names => @status_message.mentions.includes(:person => :profile).map{ |mention| mention.person.name }.join(', '))
      end

      respond_to do |format|
        format.js { render :create, :status => 201}
        format.html { redirect_to :back}
        format.mobile{ redirect_to root_url}
      end
    else
      if !photos.empty?
        photos.update_all(:status_message_id => nil)
      end
      respond_to do |format|
        format.js { render :json =>{:errors => @status_message.errors.full_messages}, :status => 422 }
        format.html {redirect_to :back}
      end
    end
  end

  def destroy
    @status_message = current_user.posts.where(:id => params[:id]).first
    if @status_message
      current_user.retract(@status_message)
      respond_to do |format|
        format.js {render 'destroy'}
        format.all {redirect_to root_url}
      end
    else
      Rails.logger.info "event=post_destroy status=failure user=#{current_user.diaspora_handle} reason='User does not own post'"
      render :nothing => true, :status => 404
    end
  end

  def show
    @status_message = current_user.find_visible_post_by_id params[:id]
    if @status_message
      @object_aspect_ids = @status_message.aspects.map{|a| a.id}

      # mark corresponding notification as read
      if notification = Notification.where(:recipient_id => current_user.id, :target_id => @status_message.id).first
        notification.unread = false
        notification.save
      end

      respond_with @status_message
    else
      Rails.logger.info(:event => :link_to_nonexistent_post, :ref => request.env['HTTP_REFERER'], :user_id => current_user.id, :post_id => params[:id])
      flash[:error] = I18n.t('status_messages.show.not_found')
      redirect_to :back
    end
  end

end
