#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Conversation, :type => :model do
  before do
    @user1 = alice
    @user2 = bob
    @participant_ids = [@user1.contacts.first.person.id, @user1.person.id]

    @create_hash = {
      :author => @user1.person,
      :participant_ids => @participant_ids,
      :subject => "cool stuff",
      :messages_attributes => [ {:author => @user1.person, :text => 'hey'} ]
    }
  end

  it 'creates a message on create' do
    expect{
      Conversation.create(@create_hash)
    }.to change(Message, :count).by(1)
  end

  describe '#last_author' do
    it 'returns the last author to a conversation' do
      cnv = Conversation.create(@create_hash)
      Message.create(:author => @user2.person, :created_at => Time.now + 100, :text => "last", :conversation_id => cnv.id)
      expect(cnv.reload.last_author.id).to eq(@user2.person.id)
    end
  end

  describe '#first_unread_message' do  
    before do
      @cnv = Conversation.create(@create_hash)
      @message = Message.create(:author => @user2.person, :created_at => Time.now + 100, :text => "last", :conversation_id => @cnv.id)
      @message.increase_unread(@user1) 
    end
    
    it 'returns the first unread message if there are unread messages in a conversation' do
      @cnv.first_unread_message(@user1) == @message
    end  

    it 'returns nil if there are no unread messages in a conversation' do
      @cnv.conversation_visibilities.where(:person_id => @user1.person.id).first.tap { |cv| cv.unread = 0 }.save
      expect(@cnv.first_unread_message(@user1)).to be_nil
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
        expect(@xml.gsub(/\s/, '')).to include(@message.to_xml.to_s.gsub(/\s/, ''))
      end

      it 'serializes the participants' do
        @create_hash[:participant_ids].each{|id|
          expect(@xml).to include(Person.find(id).diaspora_handle)
        }
      end

      it 'serializes the created_at time' do
        expect(@xml).to include(@message.created_at.to_s)
      end
    end

    describe '#subscribers' do
      it 'returns the recipients for the post owner' do
        expect(@cnv.subscribers(@user1)).to eq(@user1.contacts.map{|c| c.person})
      end
    end

    describe '#receive' do
      before do
        Message.destroy_all
        Conversation.destroy_all
      end

      it 'creates a message' do
        expect{
          Diaspora::Parser.from_xml(@xml).receive(@user1, @user2.person)
        }.to change(Message, :count).by(1)
      end
      it 'creates a conversation' do
        expect{
          Diaspora::Parser.from_xml(@xml).receive(@user1, @user2.person)
        }.to change(Conversation, :count).by(1)
      end
      it 'creates appropriate visibilities' do
        expect{
          Diaspora::Parser.from_xml(@xml).receive(@user1, @user2.person)
        }.to change(ConversationVisibility, :count).by(@participant_ids.size)
      end
      it 'does not save before receive' do
        expect(Diaspora::Parser.from_xml(@xml).persisted?).to be false
      end
      it 'notifies for the message' do
        expect(Notification).to receive(:notify).once
        Diaspora::Parser.from_xml(@xml).receive(@user1, @user2.person)
      end
    end
  end
end
