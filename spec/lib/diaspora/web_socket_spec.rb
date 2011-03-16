#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'
require File.join(Rails.root, 'lib/diaspora/web_socket')
describe Diaspora::WebSocket do
  before do
    @mock_redis = mock()
    Diaspora::WebSocket.stub(:redis).and_return @mock_redis
  end
  describe '.next' do
   it 'pops the data from redis' do
     @mock_redis.should_receive(:rpop).with(:websocket)
     Diaspora::WebSocket.next
   end
  end
  describe '.queue_to_user' do
    it 'push the data into redis' do
      @mock_redis.should_receive(:lpush).with(:websocket, {:uid => "me", :data => "Socket!"}.to_json)
      Diaspora::WebSocket.queue_to_user("me", "Socket!")
    end
  end

  describe '.subscribe' do
    it 'adds the uid to the uid redis set' do
      Diaspora::WebSocket.stub!(:length)
      Diaspora::WebSocket.initialize_channels
      @mock_redis.should_receive(:sadd).with(Diaspora::WebSocket::REDIS_CONNECTION_SET, alice.id)
      Diaspora::WebSocket.subscribe(alice.id, mock())
    end
  end

  describe '.unsubscribe' do
    it 'removes the uid to the uid redis set' do
      Diaspora::WebSocket.stub!(:length)
      Diaspora::WebSocket.initialize_channels
      @mock_redis.stub!(:sadd)
      Diaspora::WebSocket.subscribe(alice.id, mock())
      @mock_redis.should_receive(:srem).with(Diaspora::WebSocket::REDIS_CONNECTION_SET, alice.id)
      Diaspora::WebSocket.unsubscribe(alice.id, mock())
    end
  end

  describe '.is_connected?' do
    it 'calls sismember' do
      @mock_redis.should_receive(:sismember).with(Diaspora::WebSocket::REDIS_CONNECTION_SET, alice.id)
      Diaspora::WebSocket.is_connected?(alice.id)
    end
  end
end

describe Diaspora::Socketable do
  before do
    @user = alice
    @aspect = @user.aspects.first
    @post = @user.build_post(:status_message, :text => "hey", :to => @aspect.id)
    @post.save
  end

  it 'sockets to a user' do
    Diaspora::WebSocket.should_receive(:is_connected?).with(@user.id).and_return(true)
    Diaspora::WebSocket.should_receive(:queue_to_user)
    @post.socket_to_user(@user, :aspect_ids => @aspect.id)
  end
end
