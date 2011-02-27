require 'spec_helper'

describe Message do
  before do
    @user1 = alice
    @user2 = bob

    @create_hash = { :participant_ids => [@user1.contacts.first.person.id, @user1.person.id], :subject => "cool stuff" }
    @cnv = Conversation.create(@create_hash)
    @message = Message.new(:author => @user1.person, :text => "stuff")
    @cnv.messages << @message
    @message.save
    @xml = @message.to_diaspora_xml
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

  describe '#subscribers' do
    it 'returns the recipients for the post owner' do
      @message.subscribers(@user1).should == @user1.contacts.map{|c| c.person}
    end
    it 'returns the conversation author for the post owner' do
      @message.subscribers(@user2).should == @user1.person
    end
  end
  
  describe '#receive' do
    before do
      Message.delete_all
    end

    it 'creates a message' do
      lambda{
        Diaspora::Parser.from_xml(@xml).receive(@user1, @user2.person)
      }.should change(Message, :count).by(1)
    end
  end
end
