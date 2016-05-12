#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Mention, :type => :model do
  describe "#notify_recipient" do
    before do
      @user = alice
      @aspect1 = @user.aspects.create(:name => 'second_aspect')
    end

    it 'notifies the person being mentioned' do
      sm = @user.build_post(:status_message, :text => "hi @{#{bob.name}; #{bob.diaspora_handle}}", :to => @user.aspects.first)
      sm.save!
      expect(Notification).to receive(:notify).with(bob, anything(), sm.author)
      sm.notify_person(bob.person)
    end
  end

  describe '#notification_type' do
    it "returns 'mentioned'" do
     expect(Mention.new.notification_type).to eq(Notifications::Mentioned)
    end
  end

  describe 'after destroy' do
    it 'destroys a notification' do
      @user = alice
      @mentioned_user = bob

      @sm =  @user.post(:status_message, :text => "hi", :to => @user.aspects.first)
      @m  = Mention.create!(:person => @mentioned_user.person, :post => @sm)
      @m.notify_recipient

      expect{
        @m.destroy
      }.to change(Notification, :count).by(-1)
    end
  end
end

