# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

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
      @note.save
      @note.set_read_state( true )
      expect(@note.unread).to eq(false)
    end

    it "should set an read notification to unread" do
      @note.unread = false
      @note.save
      @note.set_read_state( false )
      expect(@note.unread).to eq(true)
    end
  end

  describe ".concatenate_or_create" do
    it "creates a new notification if the notification does not exist" do
      Notification.concatenate_or_create(alice, @sm, eve.person)
      notification = Notification.find_by(recipient: alice, target: @sm)
      expect(notification.actors).to eq([eve.person])
    end

    it "creates a new notification if the notification is unread" do
      @note.unread = false
      @note.save
      expect(Notification.count).to eq(1)
      Notification.concatenate_or_create(@note.recipient, @note.target, eve.person)
      expect(Notification.count).to eq(2)
    end

    it "appends the actors to the already existing notification" do
      notification = Notification.create_notification(alice, @sm, @person)
      expect {
        Notification.concatenate_or_create(alice, @sm, eve.person)
      }.to change(notification.actors, :count).by(1)
    end

    it "doesn't append the actor to an existing notification if it is already there" do
      notification = Notification.create_notification(alice, @sm, @person)
      expect {
        Notification.concatenate_or_create(alice, @sm, @person)
      }.not_to change(notification.actors, :count)
    end
  end
end

