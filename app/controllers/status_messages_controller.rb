#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

class StatusMessagesController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html
  respond_to :json, :only => :show

  def create
    params[:status_message][:to] = params[:aspect_ids]

    data = clean_hash params[:status_message]

    if @logged_in && params[:status_message][:public] == 'true'
      id = 'me'
      type = 'feed'

      Rails.logger.info("Sending a message: #{params[:status_message][:message]} to Facebook")
      @res = MiniFB.post(@access_token, id, :type=>type,
                         :metadata=>true, :params=>{:message => params[:status_message][:message]})
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
    respond_with @status_message
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
