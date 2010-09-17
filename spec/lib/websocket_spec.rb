#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

require File.dirname(__FILE__) + '/../spec_helper'

describe Diaspora::WebSocket do
  before do
    @user = Factory.create(:user)
    @aspect = @user.aspect(:name => "losers")
    @post = @user.build_post(:status_message, :message => "hey", :to => @aspect.id)
    unstub_sockets
  end

  it 'should queue a job' do
    Diaspora::WebSocket.should_receive(:queue_to_user)
    @post.socket_to_uid(@user.id, :aspect_ids => @aspect.id)
  end

  describe 'queuing and dequeuing ' do
    before do
      @post.socket_to_uid(@user.id, :aspect_ids => @aspect.id)
      @channel = Magent::GenericChannel.new('websocket')
    end

    it 'should send the queued job to Magent' do
      @channel.message_count.should == 1
    end

    it 'should dequeue the job successfully' do
      messages = @channel.message_count
      @channel.dequeue
      @channel.message_count.should == messages -1
    end
  end

end
