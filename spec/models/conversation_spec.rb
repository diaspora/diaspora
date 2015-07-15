#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require "spec_helper"

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

  context "transport" do
    let(:conversation_message) { conversation.messages.first }
    let(:xml) { conversation.to_diaspora_xml }

    before do
      conversation
    end

    describe "serialization" do
      it "serializes the message" do
        expect(xml.gsub(/\s/, "")).to include(conversation_message.to_xml.to_s.gsub(/\s/, ""))
      end

      it "serializes the participants" do
        create_hash[:participant_ids].each do |id|
          expect(xml).to include(Person.find(id).diaspora_handle)
        end
      end

      it "serializes the created_at time" do
        expect(xml).to include(conversation_message.created_at.to_s)
      end
    end

    describe "#subscribers" do
      it "returns the recipients for the post owner" do
        expect(conversation.subscribers(user1)).to eq(user1.contacts.map(&:person))
      end
    end

    describe "#receive" do
      before do
        Message.destroy_all
        Conversation.destroy_all
      end

      it "creates a message" do
        expect {
          Diaspora::Parser.from_xml(xml).receive(user1, user2.person)
        }.to change(Message, :count).by(1)
      end
      it "creates a conversation" do
        expect {
          Diaspora::Parser.from_xml(xml).receive(user1, user2.person)
        }.to change(Conversation, :count).by(1)
      end
      it "creates appropriate visibilities" do
        expect {
          Diaspora::Parser.from_xml(xml).receive(user1, user2.person)
        }.to change(ConversationVisibility, :count).by(participant_ids.size)
      end
      it "does not save before receive" do
        expect(Diaspora::Parser.from_xml(xml).persisted?).to be false
      end
      it "notifies for the message" do
        expect(Notification).to receive(:notify).once
        Diaspora::Parser.from_xml(xml).receive(user1, user2.person)
      end
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
