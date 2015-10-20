#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Notification, :type => :model do
  before do
    @sm = FactoryGirl.create(:status_message)
    @person = FactoryGirl.create(:person)
    @user = alice
    @user2 = eve
    @aspect  = @user.aspects.create(:name => "dudes")
    @opts = {:target_id => @sm.id,
      :target_type => @sm.class.base_class.to_s,
      :type => 'Notifications::CommentOnPost',
      :actors => [@person],
      :recipient_id => @user.id}
    @note = Notification.new(@opts)
  end

  it 'destoys the associated notification_actor' do
    @note.save
    expect{@note.destroy}.to change(NotificationActor, :count).by(-1)
  end

  describe '.for' do
    it 'returns all of a users notifications' do
      user2 = FactoryGirl.create(:user)
      4.times do
        Notification.create(@opts)
      end

      @opts.delete(:recipient_id)
      Notification.create(@opts.merge(:recipient_id => user2.id))

      expect(Notification.for(@user).count).to eq(4)
    end
  end

  describe 'set_read_state method' do
    it "should set an unread notification to read" do
      @note.unread = true
      @note.set_read_state( true )
      expect(@note.unread).to eq(false)
    end
    it "should set an read notification to unread" do
      @note.unread = false
      @note.set_read_state( false )
      expect(@note.unread).to eq(true)
    end

  end


  describe '.concatenate_or_create' do
    it 'creates a new notificiation if the notification does not exist, or if it is unread' do
      @note.unread = false
      @note.save
      expect(Notification.count).to eq(1)
      Notification.concatenate_or_create(@note.recipient, @note.target, @note.actors.first, Notifications::CommentOnPost)
      expect(Notification.count).to eq(2)
    end
  end
  describe '.notify' do
    context 'with a request' do
      before do
        @request = Request.diaspora_initialize(:from => @user.person, :to => @user2.person, :into => @aspect)
      end

      it 'calls Notification.create if the object has a notification_type' do
        expect(Notification).to receive(:make_notification).once
        Notification.notify(@user, @request, @person)
      end

      it "does nothing if told to notify oneself" do
        notification = Notification.notify(@user, @request, @user.person)
        expect(notification).to eq(nil)
      end

      describe '#emails_the_user' do
        it 'calls mail' do
          opts = {
            :actors => [@person],
            :recipient_id => @user.id}

            n = Notifications::StartedSharing.new(opts)
            allow(n).to receive(:recipient).and_return @user

            expect(@user).to receive(:mail)
            n.email_the_user(@request, @person)
        end
      end

      context 'multiple likes' do
        it 'concatinates the like notifications' do
          p = FactoryGirl.build(:status_message, :author => @user.person)
          person2 = FactoryGirl.build(:person)
          notification = Notification.notify(@user, FactoryGirl.build(:like, :author => @person, :target => p), @person)
          notification2 =  Notification.notify(@user, FactoryGirl.build(:like, :author => person2, :target => p), person2)
          expect(notification.id).to eq(notification2.id)
        end
      end

      context 'multiple comments' do
        it 'concatinates the comment notifications' do
          p = FactoryGirl.build(:status_message, :author => @user.person)
          person2 = FactoryGirl.build(:person)
          notification = Notification.notify(@user, FactoryGirl.build(:comment, :author => @person, :post => p), @person)
          notification2 =  Notification.notify(@user, FactoryGirl.build(:comment, :author => person2, :post => p), person2)
          expect(notification.id).to eq(notification2.id)
        end
      end

      context 'multiple people' do
        before do
          @user3 = bob
          @sm = @user3.post(:status_message, :text => "comment!", :to => :all)
          Postzord::Receiver::Private.new(@user3, :person => @user2.person, :object => @user2.comment!(@sm, "hey")).receive_object
          Postzord::Receiver::Private.new(@user3, :person => @user.person, :object => @user.comment!(@sm, "hey")).receive_object
        end

        it "updates the notification with a more people if one already exists" do
          expect(Notification.where(:recipient_id => @user3.id, :target_type => @sm.class.base_class, :target_id => @sm.id).first.actors.count).to eq(2)
        end

        it 'handles double comments from the same person without raising' do
          Postzord::Receiver::Private.new(@user3, :person => @user2.person, :object => @user2.comment!(@sm, "hey")).receive_object
          expect(Notification.where(:recipient_id => @user3.id, :target_type => @sm.class.base_class, :target_id => @sm.id).first.actors.count).to eq(2)
        end
      end
    end
  end
end

