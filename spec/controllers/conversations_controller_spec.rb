#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
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

    it "assigns a json list of contacts that are sharing with the person" do
      assigns(:contacts_json).should include(alice.contacts.where(:sharing => true).first.person.name)
      alice.contacts << Contact.new(:person_id => eve.person.id, :user_id => alice.id, :sharing => false, :receiving => true)
      assigns(:contacts_json).should_not include(alice.contacts.where(:sharing => false).first.person.name)
    end

    it "assigns a contact if passed a contact id" do
      get :new, :contact_id => alice.contacts.first.id
      assigns(:contact_ids).should == alice.contacts.first.id
    end

    it "assigns a set of contacts if passed an aspect id" do
      get :new, :aspect_id => alice.aspects.first.id
      assigns(:contact_ids).should == alice.aspects.first.contacts.map(&:id).join(',')
    end

    it "does not allow XSS via the name parameter" do
      ["</script><script>alert(1);</script>",
       '"}]});alert(1);(function f() {var foo = [{b:"'].each do |xss|
        get :new, name: xss
        response.body.should_not include xss
      end
    end
  end

  describe '#index' do
    before do
      hash = {
        :author => alice.person,
        :participant_ids => [alice.contacts.first.person.id, alice.person.id],
        :subject => 'not spam',
        :messages_attributes => [ {:author => alice.person, :text => 'cool stuff'} ]
      }
      @conversations = Array.new(3) { Conversation.create(hash) }
    end

    it 'succeeds' do
      get :index
      response.should be_success
      assigns[:conversations].should =~ @conversations
    end

    it 'succeeds with json' do
      get :index, :format => :json
      response.should be_success
      json = JSON.parse(response.body)
      json.first['conversation'].should be_present
    end

    it 'retrieves all conversations for a user' do
      get :index
      assigns[:conversations].count.should == 3
    end
  end

  describe '#create' do
    context 'with a valid conversation' do
      before do
        @hash = {
          :format => :js,
          :conversation => {
            :subject => "secret stuff",
            :text => 'text debug'
          },
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

      it 'should set response with success to true and message to success message' do
        post :create, @hash
        assigns[:response][:success].should == true
        assigns[:response][:message].should == I18n.t('conversations.create.sent')
        assigns[:response][:conversation_id].should == Conversation.first.id
      end

      it 'sets the author to the current_user' do
        @hash[:author] = FactoryGirl.create(:user)
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

        p = Postzord::Dispatcher.build(alice, cnv)
        p.class.stub(:new).and_return(p)
        p.should_receive(:post)
        post :create, @hash
      end
    end

    context 'with empty subject' do
      before do
        @hash = {
          :format => :js,
          :conversation => {
            :subject => ' ',
            :text => 'text debug'
          },
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

      it 'should set response with success to true and message to success message' do
        post :create, @hash
        assigns[:response][:success].should == true
        assigns[:response][:message].should == I18n.t('conversations.create.sent')
        assigns[:response][:conversation_id].should == Conversation.first.id
      end
    end

    context 'with empty text' do
      before do
        @hash = {
          :format => :js,
          :conversation => {
            :subject => 'secret stuff',
            :text => '  '
          },
          :contact_ids => [alice.contacts.first.id]
        }
      end

      it 'does not create a conversation' do
        lambda {
          post :create, @hash
        }.should_not change(Conversation, :count).by(1)
      end

      it 'does not create a message' do
        lambda {
          post :create, @hash
        }.should_not change(Message, :count).by(1)
      end

      it 'should set response with success to false and message to create fail' do
        post :create, @hash
        assigns[:response][:success].should == false
        assigns[:response][:message].should == I18n.t('conversations.create.fail')
      end
    end

    context 'with empty contact' do
      before do
        @hash = {
          :format => :js,
          :conversation => {
            :subject => 'secret stuff',
            :text => 'text debug'
          },
          :contact_ids => ' '
        }
      end

      it 'does not create a conversation' do
        lambda {
          post :create, @hash
        }.should_not change(Conversation, :count).by(1)
      end

      it 'does not create a message' do
        lambda {
          post :create, @hash
        }.should_not change(Message, :count).by(1)
      end

      it 'should set response with success to false and message to fail due to no contact' do
        post :create, @hash
        assigns[:response][:success].should == false
        assigns[:response][:message].should == I18n.t('conversations.create.no_contact')
      end
    end

    context 'with nil contact' do
      before do
        @hash = {
          :format => :js,
          :conversation => {
            :subject => 'secret stuff',
            :text => 'text debug'
          },
          :contact_ids => nil
        }
      end

      it 'does not create a conversation' do
        lambda {
          post :create, @hash
        }.should_not change(Conversation, :count).by(1)
      end

      it 'does not create a message' do
        lambda {
          post :create, @hash
        }.should_not change(Message, :count).by(1)
      end
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

    it 'succeeds with js' do
      get :show, :id => @conversation.id, :format => :js
      response.should be_success
      assigns[:conversation].should == @conversation
    end

    it 'succeeds with json' do
      get :show, :id => @conversation.id, :format => :json
      response.should be_success
      assigns[:conversation].should == @conversation
      response.body.should include @conversation.guid
    end

    it 'redirects to index' do
      get :show, :id => @conversation.id
      response.should redirect_to(conversations_path(:conversation_id => @conversation.id))
      assigns[:conversation].should == @conversation
    end

    it 'does not let you access conversations where you are not a recipient' do
      sign_in :user, eve

      get :show, :id => @conversation.id
      response.code.should redirect_to conversations_path
    end
  end
end
