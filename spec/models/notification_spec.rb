#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Notification do
  before do
    @sm = Factory(:status_message)
    @person = Factory(:person)
    @user = alice
    @user2 = eve
    @aspect  = @user.aspects.create(:name => "dudes")
    @opts = {:target_id => @sm.id,
      :target_type => @sm.class.name,
      :action => "comment_on_post",
      :actor_id => @person.id,
      :recipient_id => @user.id}
    @note = Notification.new(@opts)
  end

  it 'contains a type' do
    @note.target_type.should == StatusMessage.name
  end

  it 'contains a target_id' do
    @note.target_id.should == @sm.id
  end

  it 'contains a person_id' do
    @note.actor_id == @person.id
  end

  describe '.for' do
    it 'returns all of a users notifications' do
      user2 = Factory.create(:user)
      4.times do
        Notification.create(@opts)
      end

      @opts.delete(:recipient_id)
      Notification.create(@opts.merge(:recipient_id => user2.id))

      Notification.for(@user).count.should == 4
    end
  end

  describe '.notify' do
    it 'does not call Notification.create if the object does not have a notification_type' do
      Notification.should_not_receive(:create)
      Notification.notify(@user, @sm, @person)
    end
    context 'with a request' do
      before do
        @request = Request.diaspora_initialize(:from => @user.person, :to => @user2.person, :into => @aspect)
      end
      it 'calls Notification.create if the object has a notification_type' do
        Notification.should_receive(:create).once
        Notification.notify(@user, @request, @person)
      end

      it 'sockets to the recipient' do
        opts = {:target_id => @request.id,
          :target_type => "Request",
          :action => @request.notification_type(@user, @person),
          :actor_id => @person.id,
          :recipient_id => @user.id}

        n = Notification.create(opts)
        Notification.stub!(:create).and_return n

        n.should_receive(:socket_to_user).once
        Notification.notify(@user, @request, @person)
      end

      describe '#emails_the_user' do
        it 'calls mail' do
          opts = {
            :action => "new_request",
            :actor_id => @person.id,
            :recipient_id => @user.id}

            n = Notification.new(opts)
            n.stub!(:recipient).and_return @user

            @user.should_receive(:mail)
            n.email_the_user
        end
      end
    end
  end
end

