#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class StatusMessagesController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html
  respond_to :json, :only => :show

  def create

    if params[:status_message][:aspect_ids] == "all"
      params[:status_message][:aspect_ids] = current_user.aspects.collect{|x| x.id}
    end

    photos = Photo.all(:id.in => [*params[:photos]], :diaspora_handle => current_user.person.diaspora_handle)

    public_flag = params[:status_message][:public]
    public_flag.to_s.match(/(true)/) ? public_flag = true : public_flag = false
    params[:status_message][:public] = public_flag 
    @status_message = current_user.build_post(:status_message, params[:status_message])


    if @status_message.save(:safe => true)
      raise 'MongoMapper failed to catch a failed save' unless @status_message.id

      @status_message.photos += photos unless photos.nil?
      current_user.add_to_streams(@status_message, params[:status_message][:aspect_ids])
      current_user.dispatch_post(@status_message, :to => params[:status_message][:aspect_ids])

      for photo in photos
        current_user.add_to_streams(photo, params[:status_message][:aspect_ids])
        current_user.dispatch_post(photo, :to => params[:status_message][:aspect_ids])
      end

      respond_to do |format|
        format.js{ render :json => { :post_id => @status_message.id,
                                     :html => render_to_string(
                                       :partial => 'shared/stream_element', 
                                       :locals => {
                                         :post => @status_message, 
                                         :person => @status_message.person,
                                         :photos => @status_message.photos,
                                         :comments => [],
                                         :aspects => current_user.aspects, 
                                         :current_user => current_user
                                        }
                                     )
                                    },
                                     :status => 201 }
        format.html{ respond_with @status_message }
      end
    else
      respond_to do |format|
        format.js{ render :status => 406 }
      end
    end
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
      Rails.logger.info "event=post_destroy status=failure user=#{current_user.diaspora_handle} reason='User does not own post'"
    end

    respond_with :location => root_url
  end

  def show
    @status_message = current_user.find_visible_post_by_id params[:id]
    comments_hash = Comment.hash_from_post_ids [@status_message.id]
    person_hash = Person.from_post_comment_hash comments_hash
    @comment_hashes = comments_hash[@status_message.id].map do |comment|
      {:comment => comment,
        :person => person_hash[comment.person_id]
      }
    end
    respond_with @status_message
  end
end
