#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Diaspora::WebSocket do
  before do
    @user = make_user
    @aspect = @user.aspects.create(:name => "losers")
    @post = @user.build_post(:status_message, :message => "hey", :to => @aspect.id)
    @post.save
  end

  it 'should queue a job' do
    Diaspora::WebSocket.should_receive(:queue_to_user)
    @post.socket_to_uid(@user.id, :aspect_ids => @aspect.id)
  end

  describe 'queuing and dequeuing ' do
    before do
      @channel = Magent::GenericChannel.new('websocket')
      @messages = @channel.message_count
      @post.socket_to_uid(@user.id, :aspect_ids => @aspect.id)
    end

    it 'should send the queued job to Magent' do
      @channel.message_count.should == @messages + 1
    end

    it 'should dequeue the job successfully' do
      @channel.dequeue
      @channel.message_count.should == @messages
    end
  end

end
