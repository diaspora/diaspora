#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class PostsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html
  respond_to :mobile
  respond_to :json
  def show
    @post = current_user.find_visible_post_by_id params[:id]
    if @post

      # mark corresponding notification as read
      if notification = Notification.where(:recipient_id => current_user.id, :target_id => @post.id).first
        notification.unread = false
        notification.save
      end

      respond_with @post
    else
      Rails.logger.info(:event => :link_to_nonexistent_post, :ref => request.env['HTTP_REFERER'], :user_id => current_user.id, :post_id => params[:id])
      flash[:error] = I18n.t('posts.show.not_found')
      redirect_to :back
    end
  end

  def destroy
    @post = current_user.posts.where(:id => params[:id]).first
    if @post
      current_user.retract(@post)
      respond_to do |format|
        format.js {render 'destroy'}
        format.all {redirect_to root_url}
      end
    else
      Rails.logger.info "event=post_destroy status=failure user=#{current_user.diaspora_handle} reason='User does not own post'"
      render :nothing => true, :status => 404
    end
  end
end
