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
      :actors => [@person],
      :recipient_id => @user.id}
    @note = Notification.new(@opts)
    @note.actors =[ @person]
  end

  it 'contains a type' do
    @note.target_type.should == StatusMessage.name
  end

  it 'contains a target_id' do
    @note.target_id.should == @sm.id
  end


  it 'has many people' do
    @note.associations[:people].type.should == :many
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
      Notification.should_not_receive(:make_notificatin)
      Notification.notify(@user, @sm, @person)
    end
    context 'with a request' do
      before do
        @request = Request.diaspora_initialize(:from => @user.person, :to => @user2.person, :into => @aspect)
      end
      it 'calls Notification.create if the object has a notification_type' do
        Notification.should_receive(:make_notification).once
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
            n.email_the_user("mock", @person)
        end
      end

      it "updates the notification with a more people if one already exists" do
        @user3 = bob
        sm = @user3.post(:status_message, :message => "comment!", :to => :all)
        @user3.receive_object(@user2.reload.comment("hey", :on => sm), @user2.person)
        @user3.receive_object(@user.reload.comment("way", :on => sm), @user.person)
        Notification.where(:user_id => @user.id,:target_id => sm.id).first.people.count.should == 2
      end
    end
  end
end

