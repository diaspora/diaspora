#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe ConversationVisibility, :type => :model do
  before do
    @user1 = alice
    @participant_ids = [@user1.contacts.first.person.id, @user1.person.id]

    @create_hash = {
      :author => @user1.person,
      :participant_ids => @participant_ids,
      :subject => "cool stuff",
      :messages_attributes => [ {:author => @user1.person, :text => 'hey'} ]
    }
    @conversation = Conversation.create(@create_hash)
  end

  it 'destroy conversation when no participant' do
    @conversation.conversation_visibilities.each do |visibility|
      visibility.destroy
    end
      
    expect(Conversation).not_to exist(@conversation.id)
  end
end
