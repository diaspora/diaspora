#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Mention do
  describe "#notify_recipient" do
    before do
      @user = alice
      @sm =  Factory(:status_message)
      @m  = Mention.create(:person => @user.person, :post=> @sm)

    end

    it 'notifies the person being mentioned' do
      Notification.should_receive(:notify).with(@user, anything(), @sm.author)
      @m.notify_recipient
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
      @m  = Mention.create(:person => @user.person, :post => @sm)
      @m.notify_recipient

      lambda{
        @m.destroy
      }.should change(Notification, :count).by(-1)
    end
  end
end

