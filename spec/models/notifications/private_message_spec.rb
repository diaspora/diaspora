# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe Notifications::PrivateMessage, type: :model do
  let(:conversation) {
    conv_guid = Fabricate.sequence(:guid)

    Conversation.create(
      guid:                conv_guid,
      author:              alice.person,
      participant_ids:     [alice.person.id, bob.person.id],
      subject:             "cool stuff",
      messages_attributes: [{author: alice.person, text: "stuff", conversation_guid: conv_guid}]
    )
  }
  let(:msg) { conversation.messages.first }

  describe ".notify" do
    it "does not save the notification" do
      expect {
        Notifications::PrivateMessage.notify(msg, [alice.id])
      }.not_to change(Notification, :count)
    end

    it "does email the user when receiving a conversation" do
      expect(Notifications::PrivateMessage).to receive(:new).and_wrap_original do |m, *args|
        expect(args.first[:recipient].id).to eq(bob.id)
        m.call(recipient: bob)
      end
      expect(bob).to receive(:mail).with(Workers::Mail::PrivateMessage, bob.id, alice.person.id, msg.id)

      Notifications::PrivateMessage.notify(conversation, [bob.id])
    end

    it "does email the user when receiving a message" do
      expect(Notifications::PrivateMessage).to receive(:new).and_wrap_original do |m, *args|
        expect(args.first[:recipient].id).to eq(bob.id)
        m.call(recipient: bob)
      end
      expect(bob).to receive(:mail).with(Workers::Mail::PrivateMessage, bob.id, alice.person.id, msg.id)

      Notifications::PrivateMessage.notify(msg, [bob.id])
    end

    it "increases user unread count" do
      Notifications::PrivateMessage.notify(msg, [bob.id])

      expect(ConversationVisibility.where(conversation_id: conversation.id,
                                          person_id:       bob.person.id).first.unread).to eq(1)
    end

    it "increases user unread count on response" do
      message = conversation.messages.build(text: "foo bar", author: bob.person)
      message.save

      Notifications::PrivateMessage.notify(message, [alice.id])

      expect(ConversationVisibility.where(conversation_id: conversation.id,
                                          person_id:       alice.person.id).first.unread).to eq(1)
    end
  end
end
