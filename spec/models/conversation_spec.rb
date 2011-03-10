#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Conversation do
  before do
    @user1 = alice
    @user2 = bob
    @participant_ids = [@user1.contacts.first.person.id, @user1.person.id]

    @create_hash = { :author => @user1.person, :participant_ids => @participant_ids ,
                     :subject => "cool stuff", :text => 'hey'}
  end

  it 'creates a message on create' do
    lambda{
      Conversation.create(@create_hash)
    }.should change(Message, :count).by(1)
  end

  describe '#last_author' do
    it 'returns the last author to a conversation' do
      cnv = Conversation.create(@create_hash)
      Message.create(:author => @user2.person, :created_at => Time.now + 100, :text => "last", :conversation_id => cnv.id)
      cnv.reload.last_author.id.should == @user2.person.id
    end
  end


  context 'transport' do
    before do
      @cnv = Conversation.create(@create_hash)
      @message = @cnv.messages.first
      @xml = @cnv.to_diaspora_xml
    end

    describe 'serialization' do
      it 'serializes the message' do
        @xml.gsub(/\s/, '').should include(@message.to_xml.to_s.gsub(/\s/, ''))
      end

      it 'serializes the participants' do
        @create_hash[:participant_ids].each{|id|
          @xml.should include(Person.find(id).diaspora_handle)
        }
      end

      it 'serializes the created_at time' do
        @xml.should include(@message.created_at.to_s)
      end
    end

    describe '#subscribers' do
      it 'returns the recipients for the post owner' do
        @cnv.subscribers(@user1).should == @user1.contacts.map{|c| c.person}
      end
    end

    describe '#receive' do
      before do
        Conversation.destroy_all
        Message.destroy_all
      end

      it 'creates a message' do
        lambda{
          Diaspora::Parser.from_xml(@xml).receive(@user1, @user2.person)
        }.should change(Message, :count).by(1)
      end
      it 'creates a conversation' do
        lambda{
          Diaspora::Parser.from_xml(@xml).receive(@user1, @user2.person)
        }.should change(Conversation, :count).by(1)
      end
      it 'creates appropriate visibilities' do
        lambda{
          Diaspora::Parser.from_xml(@xml).receive(@user1, @user2.person)
        }.should change(ConversationVisibility, :count).by(@participant_ids.size)
      end
      it 'does not save before receive' do
        Diaspora::Parser.from_xml(@xml).persisted?.should be_false
      end
      it 'notifies for the message' do
        Notification.should_receive(:notify).once
        Diaspora::Parser.from_xml(@xml).receive(@user1, @user2.person)
      end
    end
  end
end
