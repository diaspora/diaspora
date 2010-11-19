#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class StatusMessagesController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html
  respond_to :json, :only => :show

  def create


    @photos = Photo.all(:id.in => params[:photos])

    puts @photos.inspect




    public_flag = params[:status_message][:public]
    public_flag.to_s.match(/(true)/) ? public_flag = true : public_flag = false
    params[:status_message][:public] = public_flag 

    status_message = current_user.build_post(:status_message, params[:status_message])

    status_message.photos += @photos
    if status_message.save(:safe => true)
      raise 'MongoMapper failed to catch a failed save' unless status_message.id
      current_user.dispatch_post(status_message, :to => params[:status_message][:to])
    end
    redirect_to :back 
  end


  def index
    @aspect = :profile
    @post_type = :status_messages

    @person = Person.find(params[:person_id].to_id)

    if @person
      @profile = @person.profile
      @contact = current_user.contact_for(@person)
      @is_contact = @person != current_user.person && @contact

      if @contact
        @aspects_with_person = @contact.aspects
      else
        @pending_request = current_user.pending_requests.find_by_person_id(@person.id)
      end

      @posts = current_user.visible_posts(:_type => 'StatusMessage', :person_id => @person.id).paginate :page => params[:page], :order => 'created_at DESC'
      render 'people/show'

    else
      flash[:error] = I18n.t 'people.show.does_not_exist'
      redirect_to people_path
    end
  end

  def destroy
    @status_message = current_user.my_posts.where(:_id =>  params[:id]).first
    if @status_message
      @status_message.destroy

    else
      Rails.logger.info "#{current_user.inspect} is trying to delete a post they don't own with id: #{params[:id]}"
    end

    respond_with :location => root_url
  end

  def show
    @status_message = current_user.find_visible_post_by_id params[:id]
    respond_with @status_message
  end
end
