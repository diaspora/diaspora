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

    it 'retrieves all conversations for a user' do
      hash = { :author => @user1.person, :participant_ids => [@user1.contacts.first.person.id, @user1.person.id],
               :subject => 'not spam', :text => 'cool stuff'}

      3.times do
        cnv = Conversation.create(hash)
      end

      get :index
      assigns[:conversations].count.should == 3
    end
  end

  describe '#create' do
    before do
     @hash = {:conversation => {
                :subject => "secret stuff",
                :text => 'text'},
              :contact_ids => '@user1.contacts.first.id'}
    end

    it 'creates a conversation' do
      lambda {
        post :create, @hash
      }.should change(Conversation, :count).by(1)
    end

    it 'creates a message' do
      lambda {
        post :create, @hash
      }.should change(Message, :count).by(1)
    end

    it 'sets the author to the current_user' do
      pending
      @hash[:author] = Factory.create(:user)
      post :create, @hash
      Message.first.author.should == @user1.person
      Conversation.first.author.should == @user1.person
    end

    it 'dispatches the conversation' do
      cnv = Conversation.create(@hash[:conversation].merge({
                :author => @user1.person,
                :participant_ids => [@user1.contacts.first.person.id]}))

      p = Postzord::Dispatch.new(@user1, cnv)
      Postzord::Dispatch.stub!(:new).and_return(p)
      p.should_receive(:post)
      post :create, @hash
    end
  end

  describe '#show' do
    before do
      hash = { :author => @user1.person, :participant_ids => [@user1.contacts.first.person.id, @user1.person.id],
               :subject => 'not spam', :text => 'cool stuff'}
      @conversation = Conversation.create(hash)
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
