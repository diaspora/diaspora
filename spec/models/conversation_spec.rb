# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe Conversation, :type => :model do
  let(:user1) { alice }
  let(:user2) { bob }
  let(:participant_ids) { [user1.contacts.first.person.id, user1.person.id] }
  let(:create_hash) {
    {author: user1.person, participant_ids: participant_ids,
      subject: "cool stuff", messages_attributes: [{author: user1.person, text: "hey"}]}
  }
  let(:conversation) { Conversation.create(create_hash) }
  let(:message_last) {
    Message.create(author: user2.person, created_at: Time.now + 100,
      text: "last", conversation_id: conversation.id)
  }
  let(:message_first) {
    Message.create(author: user2.person, created_at: Time.now + 100,
      text: "first", conversation_id: conversation.id)
  }

  it "creates a message on create" do
    expect { conversation }.to change(Message, :count).by(1)
  end

  describe "#last_author" do
    it "returns the last author to a conversation" do
      message_last
      expect(conversation.reload.last_author.id).to eq(user2.person.id)
    end
  end

  describe "#ordered_participants" do
    it "returns the ordered participants" do
      message_last
      expect(conversation.ordered_participants.first).to eq(user2.person)
      expect(conversation.ordered_participants.last).to eq(user1.person)
    end
  end

  describe "#first_unread_message" do
    before do
      message_last.increase_unread(user1)
    end

    it "returns the first unread message if there are unread messages in a conversation" do
      conversation.first_unread_message(user1) == message_last
    end

    it "returns nil if there are no unread messages in a conversation" do
      conversation.conversation_visibilities.where(person_id: user1.person.id).first.tap {|cv| cv.unread = 0 }.save
      expect(conversation.first_unread_message(user1)).to be_nil
    end
  end

  describe "#set_read" do
    before do
      conversation
      message_first.increase_unread(user1)
      message_last.increase_unread(user1)
    end

    it "sets the unread counter to 0" do
      expect(conversation.conversation_visibilities.where(person_id: user1.person.id).first.unread).to eq(2)
      conversation.set_read(user1)
      expect(conversation.conversation_visibilities.where(person_id: user1.person.id).first.unread).to eq(0)
    end
  end

  describe "#invalid parameters" do
    context "local author" do
      let(:invalid_hash) {
        {author: peter.person, participant_ids: [peter.person.id, user1.person.id],
          subject: "cool stuff", messages_attributes: [{author: peter.person, text: "hey"}]}
      }

      it "is invalid with invalid recipient" do
        invalid_conversation = Conversation.create(invalid_hash)
        expect(invalid_conversation).to be_invalid
      end
    end

    context "remote author" do
      let(:remote_person) { remote_raphael }
      let(:local_user) { alice }
      let(:participant_ids) { [remote_person.id, local_user.person.id] }
      let(:invalid_hash_remote) {
        {author: remote_person, participant_ids: participant_ids,
          subject: "cool stuff", messages_attributes: [{author: remote_person, text: "hey"}]}
      }

      it "is invalid with invalid recipient" do
        invalid_conversation_remote = Conversation.create(invalid_hash_remote)
        expect(invalid_conversation_remote).to be_invalid
      end
    end
  end
end
