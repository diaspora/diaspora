#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe 'making sure the spec runner works' do
  it 'factory creates a user with a person saved' do
    user = FactoryGirl.create(:user)
    loaded_user = User.find(user.id)
    expect(loaded_user.person.owner_id).to eq(user.id)
  end

  describe 'fixtures' do
    it 'loads fixtures' do
      expect(User.count).not_to eq(0)
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
      expect(contact).not_to be_nil
      expect(@user1.contacts.reload.include?(contact)).to be true
      expect(@aspect1.contacts.include?(contact)).to be true
      expect(contact.aspects.include?(@aspect1)).to be true
    end

    it 'connects the second user to the first' do
      contact = @user2.contact_for @user1.person
      expect(contact).not_to be_nil
      expect(@user2.contacts.reload.include?(contact)).to be true
      expect(@aspect2.contacts.include?(contact)).to be true
      expect(contact.aspects.include?(@aspect2)).to be true
    end

    it 'allows posting after running' do
      message = @user1.post(:status_message, :text => "Connection!", :to => @aspect1.id)
      expect(@user2.reload.visible_shareables(Post)).to include message
    end
  end

  describe '#post' do
    it 'creates a notification with a mention' do
      expect{
        alice.post(:status_message, :text => "@{Bob Grimn; #{bob.person.diaspora_handle}} you are silly", :to => alice.aspects.find_by_name('generic'))
      }.to change(Notification, :count).by(1)
    end
  end

  describe "#create_conversation_with_message" do
    it 'creates a conversation and a message' do
      conversation = create_conversation_with_message(alice, bob.person, "Subject", "Hey Bob")

      expect(conversation.participants).to eq([alice.person, bob.person])
      expect(conversation.subject).to eq("Subject")
      expect(conversation.messages.first.text).to eq("Hey Bob")
    end
  end
end
