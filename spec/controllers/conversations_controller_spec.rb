require 'spec_helper'

describe ConversationsController do
  render_views

  before do
    @user1 = alice
    sign_in :user, @user1
  end

  describe '#new' do
    it 'succeeds' do
      get :new
      response.should be_success
    end
  end

  describe '#index' do
    it 'succeeds' do
      get :index
      response.should be_success
    end

    it 'retrieves all messages for a user' do
      @conversation_hash = { :participant_ids => [@user1.contacts.first.person.id, @user1.person.id],
                             :subject => 'not spam' }
      @message_hash = {:author => @user1.person, :text => 'cool stuff'}

      3.times do
        cnv = Conversation.create(@conversation_hash)
        Message.create(@message_hash.merge({:conversation_id => cnv.id}))
      end

      get :index
      assigns[:conversations].count.should == 3
    end
  end

  describe '#create' do
    before do
     @message_hash = {:conversation => {
                    :contact_ids => [@user1.contacts.first.id],
                    :subject => "secret stuff"},
                    :message => {:text => "text"}
                    }
    end

    it 'creates a conversation' do
      lambda {
        post :create, @message_hash
      }.should change(Conversation, :count).by(1)
    end

    it 'creates a message' do
      lambda {
        post :create, @message_hash
      }.should change(Message, :count).by(1)
    end
  end

  describe '#show' do
    before do
      conversation_hash = { :participant_ids => [@user1.contacts.first.person.id, @user1.person.id],
                             :subject => 'not spam' }
      message_hash = {:author => @user1.person, :text => 'cool stuff'}

      @conversation = Conversation.create(conversation_hash)
      @message = Message.create(message_hash.merge({:conversation_id => @conversation.id}))
    end

    it 'succeeds' do
      get :show, :id => @conversation.id
      response.should be_success
      assigns[:conversation].should == @conversation
    end

    it 'does not let you access conversations where you are not a recipient' do
      user2 = eve
      sign_in :user, user2

      get :show, :id => @conversation.id
      response.code.should == '302'
    end
  end
end
