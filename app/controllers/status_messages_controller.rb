#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class StatusMessagesController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html
  respond_to :json, :only => :show

  def create
    public_flag = params[:status_message][:public]
    public_flag.to_s.match(/(true)/) ? public_flag = true : public_flag = false
    params[:status_message][:public] = public_flag 

    status_message = current_user.build_post(:status_message, params[:status_message])
    if status_message.save(:safe => true)
      raise 'MongoMapper failed to catch a failed save' unless status_message.id
      current_user.dispatch_post(status_message, :to => params[:status_message][:to])
    end
    render :nothing => true
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
