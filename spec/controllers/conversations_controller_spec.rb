require 'spec_helper'

describe ConversationsController do
  render_views

  before do
    @alice = alice
    sign_in :user, @alice
  end

  describe '#new' do
    before do
      get :new
    end
    it 'succeeds' do
      response.should be_success
    end
    it "assigns a list of the user's contacts" do
      assigns(:all_contacts_and_ids).should == @alice.contacts.collect{|c| {"value" => c.id, "name" => c.person.name}}
    end
    it "assigns a contact if passed a contact id" do
      get :new, :contact_id => @alice.contacts.first.id
      assigns(:contact).should == @alice.contacts.first
    end
  end

  describe '#index' do
    it 'succeeds' do
      get :index
      response.should be_success
    end

    it 'retrieves all conversations for a user' do
      hash = {:author => @alice.person, :participant_ids => [@alice.contacts.first.person.id, @alice.person.id],
              :subject => 'not spam', :text => 'cool stuff'}
      3.times { Conversation.create(hash) }

      get :index
      assigns[:conversations].count.should == 3
    end
  end

  describe '#create' do
    before do
      @hash = {
        :conversation => {
          :subject => "secret stuff",
          :text => 'text'},
        :contact_ids => [@alice.contacts.first.id]
      }
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
      @hash[:author] = Factory.create(:user)
      post :create, @hash
      Message.first.author.should == @alice.person
      Conversation.first.author.should == @alice.person
    end

    it 'dispatches the conversation' do
      cnv = Conversation.create(
        @hash[:conversation].merge({:author => @alice.person, :participant_ids => [@alice.contacts.first.person.id]}))

      p = Postzord::Dispatch.new(@alice, cnv)
      Postzord::Dispatch.stub!(:new).and_return(p)
      p.should_receive(:post)
      post :create, @hash
    end
  end

  describe '#show' do
    before do
      hash = {:author => @alice.person, :participant_ids => [@alice.contacts.first.person.id, @alice.person.id],
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
