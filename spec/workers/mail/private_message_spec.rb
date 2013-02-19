#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Workers::Mail::PrivateMessage do
  describe '#perfom_delegate' do
    it 'should call .deliver on the notifier object' do
      user1 = alice
      user2 = bob
      participant_ids = [user1.contacts.first.person.id, user1.person.id]

      create_hash = { :author => user1.person, :participant_ids => participant_ids ,
                       :subject => "cool stuff", :messages_attributes => [{:text => 'hey'}]}

      cnv = Conversation.create(create_hash)
      message = cnv.messages.first

      mail_mock = mock()
      mail_mock.should_receive(:deliver)
      Notifier.should_receive(:mentioned).with(user2.id, user1.person.id, message.id).and_return(mail_mock)

      Workers::Mail::Mentioned.new.perform(user2.id, user1.person.id, message.id)
    end
  end
end
