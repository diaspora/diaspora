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
    @user = make_user
    @controller = SocketsController.new
  end

  it 'un-stubs the websockets' do
    Diaspora::WebSocket.initialize_channels
    @controller.class.should == SocketsController
  end

  describe 'actionhash' do
    before do
      @aspect = @user.aspects.create(:name => "losers")
      @message = @user.post(:status_message, :message => "post through user for victory",
                            :to => @aspect.id)
      @fixture_name = File.dirname(__FILE__) + '/../fixtures/button.png'
    end

    it 'actionhashes photos' do
      photo = @user.post(:photo, :album_id => nil, :to => @aspect.id,
                         :user_file => File.open(@fixture_name))
      json  = @controller.action_hash(@user.id, photo, :aspect_ids => :all)
      json.include?('photo').should be_true
    end

    it 'actionhashes posts' do
      json = @controller.action_hash(@user.id, @message)
      json.include?(@message.message).should be_true
      json.include?('status_message').should be_true
    end

    it 'actionhashes retractions' do
      retraction = Retraction.for @message
      json = @controller.action_hash(@user.id, retraction)
      json.include?('retraction').should be_true
      json.include?("html\":null").should be_true
    end
  end
end
