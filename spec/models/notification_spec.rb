#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'


describe Notification do
  before do
    @sm = Factory(:status_message)
    @person = Factory(:person)
    @user = Factory.create(:user)
    @user2 = Factory.create(:user)
    @aspect  = @user.aspects.create(:name => "dudes")
    @opts = {:target_id => @sm.id,
      :target_type => @sm.class.name,
      :actor_id => @person.id,
      :recipient_id => @user.id}
    @note = Notification.new(@opts)
  end

  it 'contains a type' do
    @note.target_type.should == StatusMessage.name
  end

  it 'contains a object_id' do
    @note.target_id.should == @sm.id
  end

  it 'contains a person_id' do
    @note.actor_id == @person.id
  end

  describe '.for' do
    it 'returns all of a users notifications' do
      user2 = Factory.create(:user)
      Notification.create(@opts)
      Notification.create(@opts)
      Notification.create(@opts)
      Notification.create(@opts)

      @opts.delete(:user_id)
      Notification.create(@opts.merge(:recipient_id => user2.id))

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

