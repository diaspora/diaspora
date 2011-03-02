#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class MessagesController < ApplicationController
  include ApplicationHelper
  before_filter :authenticate_user!

  respond_to :html, :mobile
  respond_to :json, :only => :show

  def create
    cnv = Conversation.joins(:conversation_visibilities).where(:id => params[:conversation_id],
                              :conversation_visibilities => {:person_id => current_user.person.id}).first

    if cnv
      message = Message.new(:conversation_id => cnv.id, :text => params[:text], :author => current_user.person)
      
      if message.save
        Rails.logger.info("event=create type=comment user=#{current_user.diaspora_handle} status=success message=#{message.id} chars=#{params[:text].length}")
        Postzord::Dispatch.new(current_user, message).post

        respond_with cnv
      else
        render :nothing => true, :status => 406
      end
    else
      render :nothing => true, :status => 406
    end
  end

end
