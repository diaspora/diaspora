#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe ConversationVisibilitiesController do
  before do
    @user1 = alice
    sign_in :user, @user1

    hash = { :author => @user1.person, :participant_ids => [@user1.contacts.first.person.id, @user1.person.id],
             :subject => 'not spam', :text => 'cool stuff'}
    @conversation = Conversation.create(hash)
  end

  describe '#destroy' do
    it 'deletes the visibility' do
      lambda {
        delete :destroy, :conversation_id => @conversation.id
      }.should change(ConversationVisibility, :count).by(-1)
    end

    it 'does not let a user destroy a visibility that is not theirs' do
      user2 = eve
      sign_in :user, user2

      lambda {
        delete :destroy, :conversation_id => @conversation.id
      }.should_not change(ConversationVisibility, :count)
    end
  end
end