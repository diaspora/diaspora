#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe 'making sure the spec runner works' do
  it 'factory creates a user with a person saved' do
    user = FactoryGirl.create(:user)
    loaded_user = User.find(user.id)
    loaded_user.person.owner_id.should == user.id
  end

  describe 'fixtures' do
    it 'loads fixtures' do
      User.count.should_not == 0
    end
  end

   describe '#connect_users' do
    before do
      @user1 = User.where(:username => 'alice').first
      @user2 = User.where(:username => 'eve').first

      @aspect1 = @user1.aspects.first
      @aspect2 = @user2.aspects.first

      connect_users(@user1, @aspect1, @user2, @aspect2)
    end

    it 'connects the first user to the second' do
      contact = @user1.contact_for @user2.person
      contact.should_not be_nil
      @user1.contacts.reload.include?(contact).should be_true
      @aspect1.contacts.include?(contact).should be_true
      contact.aspects.include?(@aspect1).should be_true
    end

    it 'connects the second user to the first' do
      contact = @user2.contact_for @user1.person
      contact.should_not be_nil
      @user2.contacts.reload.include?(contact).should be_true
      @aspect2.contacts.include?(contact).should be_true
      contact.aspects.include?(@aspect2).should be_true
    end

    it 'allows posting after running' do
      message = @user1.post(:status_message, :text => "Connection!", :to => @aspect1.id)
      @user2.reload.visible_shareables(Post).should include message
    end
  end

  describe '#post' do
    it 'creates a notification with a mention' do
      lambda{
        alice.post(:status_message, :text => "@{Bob Grimn; #{bob.person.diaspora_handle}} you are silly", :to => alice.aspects.find_by_name('generic'))
      }.should change(Notification, :count).by(1)
    end
  end

  describe "#create_conversation_with_message" do
    it 'creates a conversation and a message' do
      conversation = create_conversation_with_message(alice, bob.person, "Subject", "Hey Bob")

      conversation.participants.should == [alice.person, bob.person]
      conversation.subject.should == "Subject"
      conversation.messages.first.text.should == "Hey Bob"
    end
  end
end
