#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require "spec_helper"

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

  it_behaves_like "it is relayable" do
    let(:cnv_hash) {
      {
        participant_ids:     [local_luke.person, local_leia.person, remote_raphael].map(&:id),
        subject:             "cool story, bro",
        messages_attributes: [{author: remote_raphael, text: "hey"}]
      }
    }
    let(:remote_parent) { Conversation.create(cnv_hash.merge(author: remote_raphael)) }
    let(:local_parent) { Conversation.create(cnv_hash.merge(author: local_luke.person)) }
    let(:object_on_local_parent) { Message.create(author: local_luke.person, text: "yo", conversation: local_parent) }
    let(:object_on_remote_parent) { Message.create(author: local_luke.person, text: "yo", conversation: remote_parent) }
    let(:remote_object_on_local_parent) {
      Message.create(author: remote_raphael, text: "yo", conversation: local_parent)
    }
    let(:relayable) { Message.new(author: alice.person, text: "ohai!", conversation: conversation) }
  end

  describe "#increase_unread" do
    it "increments the conversation visibility for the conversation" do
      conf = ConversationVisibility.find_by(conversation_id: conversation.id, person_id: alice.person.id)
      expect(conf.unread).to eq(0)

      message.increase_unread(alice)
      expect(conf.reload.unread).to eq(1)
    end
  end
end
