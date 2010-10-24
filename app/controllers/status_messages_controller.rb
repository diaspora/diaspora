#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class StatusMessagesController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html
  respond_to :json, :only => :show

  def create
    data = clean_hash params[:status_message]

    if logged_into_fb? && params[:status_message][:public] == '1'
      current_user.post_to_message_fb(params[:status_message][:message], @access_token)
    end

    @status_message = current_user.post(:status_message, data)
    render :nothing => true
  end

  def destroy
    @status_message = current_user.find_visible_post_by_id params[:id]
    @status_message.destroy
    respond_with :location => root_url
  end

  def show
    @status_message = current_user.find_visible_post_by_id params[:id]
    unless @status_message
      render :status => 404
    else
      respond_with @status_message
    end
  end

  private
  def clean_hash(params)
    return {
      :message => params[:message],
      :to      => params[:to],
      :public  => params[:public]
    }
  end
end
