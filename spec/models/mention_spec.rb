#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Mention do
  describe 'before create' do
    before do
      @user = alice
      @mentioned_user = bob

      @sm =  Factory(:status_message, :person => @user.person)
      @m  = Mention.new(:person => @mentioned_user.person, :post=> @sm)
    end
    it 'notifies the person being mentioned' do
      Notification.should_receive(:notify).with(@mentioned_user, @m, @sm.person)
      @m.save
    end

    it 'should only notify if the person is local' do
      m = Mention.new(:person => Factory(:person), :post => @sm)
      Notification.should_not_receive(:notify)
      m.save
    end

    it 'should only notify if the person is the user\'s friend' do
      # eve has not added alice as a contact
      @non_friend = eve

      m = Mention.new(:person => @non_friend.person, :post => @sm)
      Notification.should_not_receive(:notify)
      m.save
    end
  end

  describe '#notification_type' do
    it "returns 'mentioned'" do
     Mention.new.notification_type.should == 'mentioned'
    end
  end

  describe 'after destroy' do
    it 'destroys a notification' do
      @user = alice
      @mentioned_user = bob

      @sm =  Factory(:status_message, :person => @user.person)
      @m  = Mention.create(:person => @mentioned_user.person, :post=> @sm)

      lambda{
        @m.destroy
      }.should change(Notification, :count).by(-1)
    end
  end
end

