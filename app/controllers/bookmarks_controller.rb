#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class BookmarksController < ApplicationController
  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def create
    @bookmark = Bookmark.from_activity(params[:activity])
    @bookmark.author = current_user.person
    
    if @bookmark.save
      Rails.logger.info("event=create type=bookmark")

      current_user.add_to_streams(@bookmark, current_user.aspects)
      current_user.dispatch_post(@bookmark, :url => post_url(@bookmark))

      render :nothing => true, :status => 201
    end
  end

=begin
  def destroy
    if @bookmark = current_user.posts.where(:id => params[:id]).first
      current_user.retract(@bookmark)
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
=end

end
