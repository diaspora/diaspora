# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe Message, type: :model do
  let(:create_hash) {
    {
      author:              bob.person,
      participant_ids:     [bob.person.id, alice.person.id],
      subject:             "cool stuff",
      messages_attributes: [{author: bob.person, text: "stuff"}]
    }
  }
  let(:conversation) { Conversation.create!(create_hash) }
  let(:message) { conversation.messages.first }

  it "validates that the author is a participant in the conversation" do
    message = Message.new(text: "yo", author: eve.person, conversation_id: conversation.id)
    expect(message).not_to be_valid
  end

  describe "#subscribers" do
    let(:cnv_hash) {
      {
        participant_ids:     [local_luke.person, local_leia.person, remote_raphael].map(&:id),
        subject:             "cool story, bro",
        messages_attributes: [{author: remote_raphael, text: "hey"}]
      }
    }
    let(:local_conv) { Conversation.create(cnv_hash.merge(author: local_luke.person)) }
    let(:remote_conv) { Conversation.create(cnv_hash.merge(author: remote_raphael)) }

    it "returns all participants, if the conversation and the author is local" do
      message = Message.create(author: local_luke.person, text: "yo", conversation: local_conv)
      expect(message.subscribers).to match_array([local_luke.person, local_leia.person, remote_raphael])
    end

    it "returns all participants, if the author is local and the conversation is remote" do
      message = Message.create(author: local_luke.person, text: "yo", conversation: remote_conv)
      expect(message.subscribers).to match_array([local_luke.person, local_leia.person, remote_raphael])
    end
  end

  describe "#increase_unread" do
    it "increments the conversation visibility for the conversation" do
      conf = ConversationVisibility.find_by(conversation_id: conversation.id, person_id: alice.person.id)
      expect(conf.unread).to eq(0)

      message.increase_unread(alice)
      expect(conf.reload.unread).to eq(1)
    end
  end

  it_behaves_like "a reference source"
end
