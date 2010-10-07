#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Diaspora::Webhooks do
  before do
    @user   = Factory.create(:user)
    @aspect  = @user.aspect(:name => "losers")
    @user2   = Factory.create(:user)
    @aspect2  = @user2.aspect(:name => "losers")
    friend_users(@user, @aspect, @user2, @aspect2)
  end

  describe "body" do
    before do
      @post = Factory.build(:status_message, :person => @user.person)
    end

    it "should add the following methods to Post on inclusion" do
      @post.respond_to?(:to_diaspora_xml).should be true
    end

  end
end
