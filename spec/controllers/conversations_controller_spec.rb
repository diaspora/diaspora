#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe ConversationsController, :type => :controller do
  before do
    sign_in :user, alice
  end

  describe '#new' do
    it 'redirects to #index' do
      get :new
      expect(response).to redirect_to conversations_path
    end
  end

  describe '#new modal' do
    it 'succeeds' do
      get :new, :modal => true
      expect(response).to be_success
    end

    it "assigns a json list of contacts that are sharing with the person" do
      get :new, :modal => true
      expect(assigns(:contacts_json)).to include(alice.contacts.where(:sharing => true).first.person.name)
      alice.contacts << Contact.new(:person_id => eve.person.id, :user_id => alice.id, :sharing => false, :receiving => true)
      expect(assigns(:contacts_json)).not_to include(alice.contacts.where(:sharing => false).first.person.name)
    end

    it "assigns a contact if passed a contact id" do
      get :new, :contact_id => alice.contacts.first.id, :modal => true
      expect(assigns(:contact_ids)).to eq(alice.contacts.first.id)
    end

    it "assigns a set of contacts if passed an aspect id" do
      get :new, :aspect_id => alice.aspects.first.id, :modal => true
      expect(assigns(:contact_ids)).to eq(alice.aspects.first.contacts.map(&:id).join(','))
    end

    it "does not allow XSS via the name parameter" do
      ["</script><script>alert(1);</script>",
       '"}]});alert(1);(function f() {var foo = [{b:"'].each do |xss|
        get :new, :modal => true, name: xss
        expect(response.body).not_to include xss
      end
    end

    it "does not allow XSS via the profile name" do
      xss = "<script>alert(0);</script>"
      contact = alice.contacts.first
      contact.person.profile.update_attribute(:first_name, xss)
      get :new, :modal => true
      json = JSON.parse(assigns(:contacts_json)).first
      expect(json['value'].to_s).to eq(contact.id.to_s)
      expect(json['name']).to_not include(xss)
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
      expect(response).to be_success
      expect(assigns[:conversations]).to match_array(@conversations)
    end

    it 'succeeds with json' do
      get :index, :format => :json
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json.first['conversation']).to be_present
    end

    it 'retrieves all conversations for a user' do
      get :index
      expect(assigns[:conversations].count).to eq(3)
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
        expect {
          post :create, @hash
        }.to change(Conversation, :count).by(1)
      end

      it 'creates a message' do
        expect {
          post :create, @hash
        }.to change(Message, :count).by(1)
      end

      it 'should set response with success to true and message to success message' do
        post :create, @hash
        expect(assigns[:response][:success]).to eq(true)
        expect(assigns[:response][:message]).to eq(I18n.t('conversations.create.sent'))
        expect(assigns[:response][:conversation_id]).to eq(Conversation.first.id)
      end

      it 'sets the author to the current_user' do
        @hash[:author] = FactoryGirl.create(:user)
        post :create, @hash
        expect(Message.first.author).to eq(alice.person)
        expect(Conversation.first.author).to eq(alice.person)
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
        allow(p.class).to receive(:new).and_return(p)
        expect(p).to receive(:post)
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
        expect {
          post :create, @hash
        }.to change(Conversation, :count).by(1)
      end

      it 'creates a message' do
        expect {
          post :create, @hash
        }.to change(Message, :count).by(1)
      end

      it 'should set response with success to true and message to success message' do
        post :create, @hash
        expect(assigns[:response][:success]).to eq(true)
        expect(assigns[:response][:message]).to eq(I18n.t('conversations.create.sent'))
        expect(assigns[:response][:conversation_id]).to eq(Conversation.first.id)
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
        count = Conversation.count
        post :create, @hash
        expect(Conversation.count).to eq(count)
      end

      it 'does not create a message' do
        count = Message.count
        post :create, @hash
        expect(Message.count).to eq(count)
      end

      it 'should set response with success to false and message to create fail' do
        post :create, @hash
        expect(assigns[:response][:success]).to eq(false)
        expect(assigns[:response][:message]).to eq(I18n.t('conversations.create.fail'))
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
        count = Conversation.count
        post :create, @hash
        expect(Conversation.count).to eq(count)
      end

      it 'does not create a message' do
        count = Message.count
        post :create, @hash
        expect(Message.count).to eq(count)
      end

      it 'should set response with success to false and message to fail due to no contact' do
        post :create, @hash
        expect(assigns[:response][:success]).to eq(false)
        expect(assigns[:response][:message]).to eq(I18n.t('conversations.create.no_contact'))
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
        count = Conversation.count
        post :create, @hash
        expect(Conversation.count).to eq(count)
      end

      it 'does not create a message' do
        count = Message.count
        post :create, @hash
        expect(Message.count).to eq(count)
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
      xhr :get, :show, :id => @conversation.id, :format => :js
      expect(response).to be_success
      expect(assigns[:conversation]).to eq(@conversation)
    end

    it 'succeeds with json' do
      get :show, :id => @conversation.id, :format => :json
      expect(response).to be_success
      expect(assigns[:conversation]).to eq(@conversation)
      expect(response.body).to include @conversation.guid
    end

    it 'redirects to index' do
      get :show, :id => @conversation.id
      expect(response).to redirect_to(conversations_path(:conversation_id => @conversation.id))
      expect(assigns[:conversation]).to eq(@conversation)
    end

    it 'does not let you access conversations where you are not a recipient' do
      sign_in :user, eve

      get :show, :id => @conversation.id
      expect(response.code).to redirect_to conversations_path
    end
  end
end
