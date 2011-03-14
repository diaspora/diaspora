#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Mention do
  describe "#notify_recipient" do
    before do
      @user = alice
      @aspect1 = @user.aspects.create(:name => 'second_aspect')
      @mentioned_user = bob
      @non_friend = eve

      @sm = @user.build_post(:status_message, :text => "hi @{#{@mentioned_user.name}; #{@mentioned_user.diaspora_handle}}", :to => @user.aspects.first)
    end

    it 'notifies the person being mentioned' do
      Notification.should_receive(:notify).with(@mentioned_user, anything(), @sm.author)
      @sm.receive(@mentioned_user, @mentioned_user.person)
    end

    it 'should not notify a user if they do not see the message' do
      connect_users(@user, @aspect1, @non_friend, @non_friend.aspects.first)

      Notification.should_not_receive(:notify).with(@mentioned_user, anything(), @user.person)
      sm2 = @user.post(:status_message, :text => "stuff @{#{@non_friend.name}; #{@non_friend.diaspora_handle}}", :to => @user.aspects.first)
      sm2.receive(@non_friend, @non_friend.person)
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
      @mentioned_user = bob

      @sm =  @user.post(:status_message, :text => "hi", :to => @user.aspects.first)
      @m  = Mention.create!(:person => @mentioned_user.person, :post => @sm)
      @m.notify_recipient

      lambda{
        @m.destroy
      }.should change(Notification, :count).by(-1)
    end
  end
end

