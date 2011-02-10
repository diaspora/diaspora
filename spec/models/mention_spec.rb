#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Mention do
  describe 'before create' do
    before do
      @user = alice
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
  end

  describe '#notification_type' do
    it "returns 'mentioned'" do
     Mention.new.notification_type.should == 'mentioned' 
    end
  end
end

