#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

require File.dirname(__FILE__) + '/../spec_helper'

describe Diaspora::WebSocket do
  before do
    @user = Factory.create(:user)
    @aspect = @user.aspect(:name => "losers")
    @post = @user.build_post(:status_message, :message => "hey", :to => @aspect.id)
  end

  it 'should queue a job' do
    Diaspora::WebSocket.should_receive(:queue_to_user)
    @post.socket_to_uid(@user.id, :aspect_ids => @aspect.id)
  end

  it 'The queued job should reach Magent' do
    Magent.should_receive(:push)
    @post.socket_to_uid(@user.id, :aspect_ids => @aspect.id)
  end

end
