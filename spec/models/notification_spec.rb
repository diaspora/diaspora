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
      :type => 'Notifications::CommentOnPost',
      :actors => [@person],
      :recipient_id => @user.id}
    @note = Notification.new(@opts)
    @note.actors =[ @person]
  end

  it 'destoys the associated notification_actor' do
    @note.save
    lambda{@note.destroy}.should change(NotificationActor, :count).by(-1)
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

      it 'creates the notification already read' do
        n = Notification.notify(@user, @request, @person)
        n.unread?.should be_false
      end

      it 'sockets to the recipient' do
        opts = {:target_id => @request.id,
          :target_type => "Request",
          :actors => [@person],
          :recipient_id => @user.id}

        n = @request.notification_type(@user, @person).create(opts)
        Notification.stub!(:make_notification).and_return n

        n.should_receive(:socket_to_user).once
        Notification.notify(@user, @request, @person)
      end

      describe '#emails_the_user' do
        it 'calls mail' do
          opts = {
            :actors => [@person],
            :recipient_id => @user.id}

            n = Notifications::NewRequest.new(opts)
            n.stub!(:recipient).and_return @user

            @user.should_receive(:mail)
            n.email_the_user(@request, @person)
        end
      end

      context 'multiple people' do

        before do
          @user3 = bob
          @sm = @user3.post(:status_message, :text => "comment!", :to => :all)
          Postzord::Receiver.new(@user3, :person => @user2.person, :object => @user2.comment("hey", :on => @sm)).receive_object
          Postzord::Receiver.new(@user3, :person => @user.person, :object => @user.comment("hey", :on => @sm)).receive_object
        end

        it "updates the notification with a more people if one already exists" do
          Notification.where(:recipient_id => @user3.id, :target_type => @sm.class.base_class, :target_id => @sm.id).first.actors.count.should == 2
        end

        it 'handles double comments from the same person without raising' do
          Postzord::Receiver.new(@user3, :person => @user2.person, :object => @user2.comment("hey", :on => @sm)).receive_object
          Notification.where(:recipient_id => @user3.id, :target_type => @sm.class.base_class, :target_id => @sm.id).first.actors.count.should == 2
        end

        it 'marks the notification as unread' do
          note = Notification.where(:recipient_id => @user3.id,:target_type => @sm.class.base_class, :target_id => @sm.id).first
          note.unread = false
          note.save
          lambda {
            Postzord::Receiver.new(@user3, :person => @user2.person, :object => @user2.comment("hey", :on => @sm)).receive_object
            note.reload
          }.should change(note, :unread).from(false).to(true)
        end
      end
    end
  end
end

