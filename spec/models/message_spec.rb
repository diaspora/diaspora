#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'
require File.join(Rails.root, "spec", "lib", "diaspora", "relayable_spec")

describe Message do
  before do
    @user1 = alice
    @user2 = bob

    @create_hash = { :participant_ids => [@user1.contacts.first.person.id, @user1.person.id], :subject => "cool stuff",
                     :message => {:author => @user1.person, :text => "stuff"} }
    @cnv = Conversation.create(@create_hash)
    @message = @cnv.messages.first
    @xml = @message.to_diaspora_xml
  end

  describe '#after_initialize' do
    before do
      @create_hash = { :participant_ids => [@user1.contacts.first.person.id, @user1.person.id], :subject => "cool stuff"}

      @cnv = Conversation.new(@create_hash)
      @cnv.save
      @msg = Message.new(:text => "21312", :conversation => @cnv)
    end
    it 'signs the message' do
      @msg.author_signature.should_not be_blank
    end

    it 'signs the message author if author of conversation' do
      @msg.parent_author_signature.should_not be_blank
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

      cnv_hash = {:subject => 'cool story, bro', :participant_ids => [@local_luke.person, @local_leia.person, @remote_raphael].map(&:id),
                  :message => {:author => @remote_raphael, :text => 'hey'}}

      @remote_parent = Conversation.create(cnv_hash.dup)

      cnv_hash[:message][:author] = @local_luke.person
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
  end
end
