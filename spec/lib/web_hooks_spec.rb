require File.dirname(__FILE__) + '/../spec_helper'

include Diaspora

describe Diaspora do

  describe Webhooks do
    before do
      @user   = Factory.create(:user)
      @group  = @user.group(:name => "losers")
      @user2   = Factory.create(:user)
      @group2  = @user2.group(:name => "losers")
      friend_users(@user, @group, @user2, @group2)
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
end
