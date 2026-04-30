# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe Mail::PrivateMessageWorker do
  describe "#perform" do
    it "should call .deliver on the notifier object" do
      user1 = alice
      user2 = bob
      participant_ids = [user1.contacts.first.person.id, user1.person.id]

      create_hash = { :author => user1.person, :participant_ids => participant_ids ,
                       :subject => "cool stuff", :messages_attributes => [{:text => 'hey'}]}

      cnv = Conversation.create(create_hash)
      message = cnv.messages.first

      mail_double = double()
      expect(mail_double).to receive(:deliver_now)
      expect(Notifier).to receive(:send_notification)
        .with("private_message", user2.id, user1.person.id, message.id).and_return(mail_double)

      Mail::PrivateMessageWorker.new.perform(user2.id, user1.person.id, message.id)
    end
  end
end
