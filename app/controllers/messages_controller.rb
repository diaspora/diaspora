#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class MessagesController < ApplicationController
  before_action :authenticate_user!

  respond_to :html, :mobile
  respond_to :json, :only => :show

  def create
    conversation = Conversation.find(params[:conversation_id])

    opts = params.require(:message).permit(:text)
    message = current_user.build_message(conversation, opts)

    if message.save
      Rails.logger.info("event=create type=comment user=#{current_user.diaspora_handle} status=success message=#{message.id} chars=#{params[:message][:text].length}")
      Postzord::Dispatcher.build(current_user, message).post
    else
      flash[:error] = I18n.t('conversations.new_conversation.fail')
    end
    redirect_to conversations_path(:conversation_id => conversation.id)
  end
end
