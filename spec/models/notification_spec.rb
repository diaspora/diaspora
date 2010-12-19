#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'


describe Notification do 
  before do
    @sm = Factory(:status_message)
    @person = Factory(:person)
    @user = make_user
    @user2 = make_user
    @aspect  = @user.aspects.create(:name => "dudes")
    @opts = {:object_id => @sm.id, :kind => @sm.class.name, :person_id => @person.id, :user_id => @user.id}
    @note = Notification.new(@opts)
  end

  it 'contains a type' do
    @note.kind.should == StatusMessage.name
  end

  it 'contains a object_id' do
    @note.object_id.should == @sm.id
  end

  it 'contains a person_id' do
    @note.person.id == @person.id
  end

  describe '.for' do
    it 'returns all of a users notifications' do
      user2 = make_user
      Notification.create(@opts)
      Notification.create(@opts)
      Notification.create(@opts)
      Notification.create(@opts)
      
      @opts.delete(:user_id)
      Notification.create(@opts.merge(:user_id => user2.id))

      Notification.for(@user).count.should == 4
    end
  end

  describe '.notify' do
    it ' does not call Notification.create if the object does not notification_type' do
      Notification.should_not_receive(:create)
      Notification.notify(@user, @sm, @person)
    end

    it ' does not call Notification.create if the object does not notification_type' do
      request = Request.diaspora_initialize(:from => @user.person, :to => @user2.person, :into => @aspect)
      Notification.should_receive(:create).once
      Notification.notify(@user, request, @person)
    end
  end
end

