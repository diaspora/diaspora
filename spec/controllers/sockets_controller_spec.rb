#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

SocketsController.class_eval <<-EOT
  def url_options
    {:host => ""}
  end
EOT

describe SocketsController do
  render_views
  before do
    @user = alice
    @controller = SocketsController.new
    @aspect = @user.aspects.first
    @message = @user.post :status_message, :text => "post through user for victory", :to => @aspect.id
  end

  describe 'actionhash' do
    it 'actionhashes posts' do
      json = @controller.action_hash(@user, @message)
      json.include?(@message.text).should be_true
      json.include?('status_message').should be_true
    end

    it 'actionhashes retractions' do
      retraction = Retraction.for @message
      json = @controller.action_hash(@user, retraction)
      json.include?('retraction').should be_true
      json.include?("html\":null").should be_true
    end
  end
  describe '#outgoing' do
    it 'calls queue_to_user' do
      Diaspora::WebSocket.should_receive(:is_connected?).with(@user.id).and_return(true)
      Diaspora::WebSocket.should_receive(:queue_to_user).with(@user.id, anything)
      @controller.outgoing(@user, @message)
    end

    it 'does not call queue_to_user if the user is not connected' do
      Diaspora::WebSocket.should_receive(:is_connected?).with(@user.id).and_return(false)
      Diaspora::WebSocket.should_not_receive(:queue_to_user)
      @controller.outgoing(@user, @message)
    end
  end
end
