#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe ConversationVisibilitiesController do
  render_views

  before do
    @user1 = alice
    sign_in :user, @user1

    @create_hash = { :participant_ids => [@user1.contacts.first.person.id, @user1.person.id],
    :subject => "cool stuff" }
    @conversation = Conversation.create(@create_hash)
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
