#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class StatusMessagesController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html
  respond_to :json, :only => :show

  def create
    params[:status_message][:aspect_ids] = params[:aspect_ids]

    photos = Photo.all(:id.in => [*params[:photos]], :diaspora_handle => current_user.person.diaspora_handle)

    public_flag = params[:status_message][:public]
    public_flag.to_s.match(/(true)/) ? public_flag = true : public_flag = false
    params[:status_message][:public] = public_flag
    @status_message = current_user.build_post(:status_message, params[:status_message])


    if photos || @status_message.save!(:safe => true)
      raise 'MongoMapper failed to catch a failed save' unless @status_message.id

      @status_message.photos += photos unless photos.nil?
      current_user.add_to_streams(@status_message, params[:status_message][:aspect_ids])
      current_user.dispatch_post(@status_message, :to => params[:status_message][:aspect_ids], :url => post_url(@status_message))


      for photo in photos
        photo.public = public_flag
        photo.save
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
                                         :all_aspects => current_user.aspects,
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

  def destroy
    @status_message = current_user.my_posts.where(:_id =>  params[:id]).first
    if @status_message
      @status_message.destroy
      render :nothing => true, :status => 200
    else
      Rails.logger.info "event=post_destroy status=failure user=#{current_user.diaspora_handle} reason='User does not own post'"
      render :nothing => true, :status => 404
    end
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

    @object_aspect_ids = @status_message.aspects.map{|a| a.id}

    respond_with @status_message
  end
end
