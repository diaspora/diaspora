# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe ConversationVisibility, type: :model do
  let(:user1) { alice }
  let(:participant_ids) { [user1.contacts.first.person.id, user1.person.id] }
  let(:create_hash) {
    {author: user1.person, participant_ids: participant_ids, subject: "cool stuff",
      messages_attributes: [{author: user1.person, text: "hey"}]}
  }
  let(:conversation) { Conversation.create(create_hash) }

  it "destroy conversation when no participant" do
    conversation.conversation_visibilities.each(&:destroy)

    expect(Conversation).not_to exist(conversation.id)
  end
end
