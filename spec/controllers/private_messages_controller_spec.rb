require 'spec_helper'

describe PrivateMessagesController do
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
      @create_hash = { :participant_ids => [@user1.contacts.first.person.id, @user1.person.id],
      :author => @user1.person, :message => "cool stuff" }
      3.times do
        PrivateMessage.create(@create_hash)
      end

      get :index
      assigns[:messages].count.should == 3
    end
  end

  describe '#create' do
    it 'creates a private message' do
     message_hash = {:private_message => {
                    :contact_ids => [@user1.contacts.first.id],
                    :message => "secret stuff"}}


      lambda {
        post :create, message_hash
      }.should change(PrivateMessage, :count).by(1)
    end
  end

  describe '#show' do
    before do
      @create_hash = { :participant_ids => [@user1.contacts.first.person.id, @user1.person.id],
      :author => @user1.person, :message => "cool stuff" }
      @message = PrivateMessage.create(@create_hash)
    end

    it 'succeeds' do
      get :show, :id => @message.id
      response.should be_success
      assigns[:message].should == @message
    end

    it 'does not let you access messages where you are not a recipient' do
      user2 = eve
      sign_in :user, user2

      get :show, :id => @message.id
      response.code.should == '302'
    end
  end
end
