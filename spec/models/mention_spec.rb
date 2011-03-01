#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Mention do
  describe 'before create' do
    before do
      @user = alice
      @aspect1 = @user.aspects.create(:name => 'second_aspect')
      @mentioned_user = bob
      @non_friend = eve

      @sm =  Factory(:status_message)
      @m  = Mention.new(:person => @user.person, :post=> @sm)

    end
    it 'notifies the person being mention' do
      Notification.should_receive(:notify).with(@user, @m, @sm.person)
      @m.save
    end

    it 'should only notify if the person is local' do
      m = Mention.new(:person => Factory(:person), :post => @sm)
      Notification.should_not_receive(:notify)
      m.save
    end

    it 'should not notify a user if they do not see the message' do
      pending "this is for mnutt"
      connect_users(@user, @aspect1, @non_friend, @non_friend.aspects.first)

      Notification.should_not_receive(:notify).with(@mentioned_user, anything(), @user.person)
      sm2 = @user.build_post(:status_message, :message => 'stuff')
      sm2.stub!(:socket_to_user)
      @user.add_to_streams(sm2, [@aspect1])
      m2 = Mention.new(:person => @mentioned_user.person, :post => @sm)
      sm2.save
      m2.save
    end

  end

  describe '#notification_type' do
    it "returns 'mentioned'" do
     Mention.new.notification_type.should == Notifications::Mentioned
    end
  end

  describe 'after destroy' do
    it 'destroys a notification' do
      @user = alice
      @sm =  Factory(:status_message)
      @m  = Mention.create(:person => @user.person, :post=> @sm)

      lambda{
        @m.destroy
      }.should change(Notification, :count).by(-1)
    end
  end
end

