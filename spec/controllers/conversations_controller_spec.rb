#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe ConversationsController do
  before do
    sign_in :user, alice
  end

  describe '#new' do
    before do
      get :new
    end

    it 'succeeds' do
      response.should be_success
    end

    it "assigns a json list of contacts" do
      assigns(:contacts_json).should include(alice.contacts.first.person.name)
    end

    it "assigns a contact if passed a contact id" do
      get :new, :contact_id => alice.contacts.first.id
      assigns(:contact_ids).should == alice.contacts.first.id
    end

    it "assigns a set of contacts if passed an aspect id" do
      get :new, :aspect_id => alice.aspects.first.id
      assigns(:contact_ids).should == alice.aspects.first.contacts.map(&:id).join(',')
    end
  end

  describe '#index' do
    it 'succeeds' do
      get :index
      response.should be_success
    end

    it 'retrieves all conversations for a user' do
      hash = {
        :author => alice.person,
        :participant_ids => [alice.contacts.first.person.id, alice.person.id],
        :subject => 'not spam',
        :messages_attributes => [ {:author => alice.person, :text => 'cool stuff'} ]
      }
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
        :contact_ids => [alice.contacts.first.id]
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
      Message.first.author.should == alice.person
      Conversation.first.author.should == alice.person
    end

    it 'dispatches the conversation' do
      cnv = Conversation.create(
        {
          :author => alice.person,
          :participant_ids => [alice.contacts.first.person.id, alice.person.id],
          :subject => 'not spam',
          :messages_attributes => [ {:author => alice.person, :text => 'cool stuff'} ]
        }
      )
      p = Postzord::Dispatch.new(alice, cnv)
      Postzord::Dispatch.stub!(:new).and_return(p)
      p.should_receive(:post)
      post :create, @hash
    end
  end

  describe '#show' do
    before do
      hash = {
        :author => alice.person,
        :participant_ids => [alice.contacts.first.person.id, alice.person.id],
        :subject => 'not spam',
        :messages_attributes => [ {:author => alice.person, :text => 'cool stuff'} ]
      }
      @conversation = Conversation.create(hash)
    end

    it 'succeeds' do
      get :show, :id => @conversation.id
      response.should be_success
      assigns[:conversation].should == @conversation
    end

    it 'does not let you access conversations where you are not a recipient' do
      sign_in :user, eve

      get :show, :id => @conversation.id
      response.code.should redirect_to conversations_path
    end
  end
end
