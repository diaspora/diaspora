#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'
require File.join(Rails.root, "spec", "shared_behaviors", "relayable")

describe Message do
  before do
    @user1 = alice
    @user2 = bob

    @create_hash = { :author => @user1.person, :participant_ids => [@user1.contacts.first.person.id, @user1.person.id],
                     :subject => "cool stuff", :text => "stuff"}

    @cnv = Conversation.create(@create_hash)
    @message = @cnv.messages.first
    @xml = @message.to_diaspora_xml
  end

  it 'validates that the author is a participant in the conversation' do
    msg = Message.new(:text => 'yo', :author => eve.person, :conversation_id => @cnv.id)
  end

  describe '#notification_type' do
    it 'does not return anything for the author' do
      @message.notification_type(@user1, @user1.person).should be_nil
    end

    it 'returns private mesage for an actual receiver' do
      @message.notification_type(@user2, @user1.person).should == Notifications::PrivateMessage
    end
  end

  describe '#before_create' do
    it 'signs the message' do
      @message.author_signature.should_not be_blank
    end

    it 'signs the message author if author of conversation' do
      @message.parent_author_signature.should_not be_blank
    end
  end

  describe 'serialization' do
    it 'serializes the text' do
      @xml.should include(@message.text)
    end

    it 'serializes the author_handle' do
      @xml.should include(@message.author.diaspora_handle)
    end

    it 'serializes the created_at time' do
      @xml.should include(@message.created_at.to_s)
    end

    it 'serializes the conversation_guid time' do
      @xml.should include(@message.conversation.guid)
    end
  end

  describe 'it is relayable' do
    before do
      @local_luke, @local_leia, @remote_raphael = set_up_friends

      cnv_hash = {:author => @remote_raphael, :participant_ids => [@local_luke.person, @local_leia.person, @remote_raphael].map(&:id),
                  :subject => 'cool story, bro', :text => 'hey'}

      @remote_parent = Conversation.create(cnv_hash.dup)

      cnv_hash[:author] = @local_luke.person
      @local_parent = Conversation.create(cnv_hash)

      msg_hash = {:author => @local_luke.person, :text => 'yo', :conversation => @local_parent}
      @object_by_parent_author = Message.create(msg_hash.dup)
      Postzord::Dispatch.new(@local_luke, @object_by_parent_author).post

      msg_hash[:author] = @local_leia.person
      @object_by_recipient = Message.create(msg_hash.dup)

      @dup_object_by_parent_author = @object_by_parent_author.dup

      msg_hash[:author] = @local_luke.person
      msg_hash[:conversation] = @remote_parent
      @object_on_remote_parent = Message.create(msg_hash)
      Postzord::Dispatch.new(@local_luke, @object_on_remote_parent).post
    end
    it_should_behave_like 'it is relayable'

    describe '#after_receive' do
      it 'increments the conversation visiblity for the conversation' do
       ConversationVisibility.where(:conversation_id => @object_by_recipient.reload.conversation.id,
                                                     :person_id => @local_luke.person.id).first.unread.should == 0
  
        @object_by_recipient.receive(@local_luke, @local_leia.person)
        ConversationVisibility.where(:conversation_id => @object_by_recipient.reload.conversation.id,
                                                     :person_id => @local_luke.person.id).first.unread.should == 1
      end
    end
  end
end
