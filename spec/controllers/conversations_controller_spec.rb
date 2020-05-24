# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe ConversationsController, :type => :controller do
  before do
    sign_in alice, scope: :user
  end

  describe '#new' do
    it 'redirects to #index' do
      get :new
      expect(response).to redirect_to conversations_path
    end
  end

  describe "#new modal" do
    context "desktop" do
      it "succeeds" do
        get :new, params: {modal: true}
        expect(response).to be_successful
      end
    end

    context "mobile" do
      before do
        controller.session[:mobile_view] = true
      end

      it "assigns a json list of contacts that are sharing with the person" do
        sharing_user = FactoryGirl.create(:user_with_aspect)
        sharing_user.share_with(alice.person, sharing_user.aspects.first)
        get :new, params: {modal: true}
        expect(assigns(:contacts_json))
          .to include(alice.contacts.where(sharing: true, receiving: true).first.person.name)
        alice.contacts << Contact.new(person_id: eve.person.id, user_id: alice.id, sharing: false, receiving: true)
        expect(assigns(:contacts_json)).not_to include(alice.contacts.where(sharing: false).first.person.name)
        expect(assigns(:contacts_json)).not_to include(alice.contacts.where(receiving: false).first.person.name)
      end

      it "does not allow XSS via the name parameter" do
        ["</script><script>alert(1);</script>",
         '"}]});alert(1);(function f() {var foo = [{b:"'].each do |xss|
          get :new, params: {modal: true, name: xss}
          expect(response.body).not_to include xss
        end
      end

      it "does not allow XSS via the profile name" do
        xss     = "<script>alert(0);</script>"
        contact = alice.contacts.first
        contact.person.profile.update_attribute(:first_name, xss)
        get :new, params: {modal: true}
        json = JSON.parse(assigns(:contacts_json)).first
        expect(json["value"].to_s).to eq(contact.id.to_s)
        expect(json["name"]).to_not include(xss)
      end
    end
  end

  describe "#index" do
    before do
      hash = {
        author:              alice.person,
        participant_ids:     [alice.contacts.first.person.id, alice.person.id],
        subject:             "not spam",
        messages_attributes: [{author: alice.person, text: "**cool stuff**"}]
      }
      @conversations = Array.new(3) { Conversation.create(hash) }
      @visibilities = @conversations.map {|conversation|
        conversation.conversation_visibilities.find {|visibility| visibility.person == alice.person }
      }
    end

    it "succeeds" do
      get :index
      expect(response).to be_successful
      expect(assigns[:visibilities]).to match_array(@visibilities)
    end

    it "succeeds with json" do
      get :index, format: :json
      expect(response).to be_successful
      json = JSON.parse(response.body)
      expect(json.first["conversation"]).to be_present
    end

    it "retrieves all conversations for a user" do
      get :index
      expect(assigns[:visibilities].count).to eq(3)
    end

    it "retrieves a conversation" do
      get :index, params: {conversation_id: @conversations.first.id}
      expect(response).to be_successful
      expect(assigns[:visibilities]).to match_array(@visibilities)
      expect(assigns[:conversation]).to eq(@conversations.first)
    end

    it "does not let you access conversations where you are not a recipient" do
      sign_in eve, scope: :user
      get :index, params: {conversation_id: @conversations.first.id}
      expect(assigns[:conversation]).to be_nil
    end

    it "retrieves a conversation message with out markdown content " do
      get :index
      @conversation = @conversations.first
      expect(response).to be_successful
      expect(response.body).to match(/cool stuff/)
      expect(response.body).not_to match(%r{<strong>cool stuff</strong>})
    end
  end

  describe "#create" do
    context "desktop" do
      context "with a valid conversation" do
        let(:params) {
          {
            conversation: {subject: "secret stuff", text: "text debug"},
            person_ids:   alice.contacts.first.person.id.to_s
          }
        }

        it "creates a conversation" do
          expect { post :create, params: params, format: :js }.to change(Conversation, :count).by(1)
        end

        it "creates a message" do
          expect { post :create, params: params, format: :js }.to change(Message, :count).by(1)
        end

        it "responds with the conversation id as JSON" do
          post :create, params: params, format: :js
          expect(response).to be_successful
          expect(JSON.parse(response.body)["id"]).to eq(Conversation.first.id)
        end

        it "sets the author to the current_user" do
          params[:author] = FactoryGirl.create(:user)
          post :create, params: params, format: :js
          expect(Message.first.author).to eq(alice.person)
          expect(Conversation.first.author).to eq(alice.person)
        end

        it "dispatches the conversation" do
          Conversation.create(author:  alice.person, participant_ids: [alice.contacts.first.person.id, alice.person.id],
                              subject: "not spam", messages_attributes: [{author: alice.person, text: "cool stuff"}])

          expect(Diaspora::Federation::Dispatcher).to receive(:defer_dispatch)
          post :create, params: params, format: :js
        end
      end

      context "with empty subject" do
        let(:params) {
          {
            conversation: {subject: " ", text: "text debug"},
            person_ids:   alice.contacts.first.person.id.to_s
          }
        }

        it "creates a conversation" do
          expect { post :create, params: params, format: :js }.to change(Conversation, :count).by(1)
        end

        it "creates a message" do
          expect { post :create, params: params, format: :js }.to change(Message, :count).by(1)
        end

        it "responds with the conversation id as JSON" do
          post :create, params: params, format: :js
          expect(response).to be_successful
          expect(JSON.parse(response.body)["id"]).to eq(Conversation.first.id)
        end
      end

      context "with empty text" do
        let(:params) {
          {
            conversation: {subject: "secret stuff", text: "  "},
            person_ids:   alice.contacts.first.person.id.to_s
          }
        }

        it "does not create a conversation" do
          expect { post :create, params: params, format: :js }.not_to change(Conversation, :count)
        end

        it "does not create a message" do
          expect { post :create, params: params, format: :js }.not_to change(Message, :count)
        end

        it "responds with an error message" do
          post :create, params: params, format: :js
          expect(response).not_to be_successful
          expect(response.body).to eq(I18n.t("conversations.create.fail"))
        end
      end

      context "with empty contact" do
        let(:params) {
          {
            conversation: {subject: "secret stuff", text: "text debug"},
            person_ids:   " "
          }
        }

        it "does not create a conversation" do
          expect { post :create, params: params, format: :js }.not_to change(Conversation, :count)
        end

        it "does not create a message" do
          expect { post :create, params: params, format: :js }.not_to change(Message, :count)
        end

        it "responds with an error message" do
          post :create, params: params, format: :js
          expect(response).not_to be_successful
          expect(response.body).to eq(I18n.t("javascripts.conversation.create.no_recipient"))
        end
      end

      context "with nil contact" do
        let(:params) {
          {
            conversation: {subject: "secret stuff", text: "text debug"},
            person_ids:   nil
          }
        }

        it "does not create a conversation" do
          expect { post :create, params: params, format: :js }.not_to change(Conversation, :count)
        end

        it "does not create a message" do
          expect { post :create, params: params, format: :js }.not_to change(Message, :count)
        end

        it "responds with an error message" do
          post :create, params: params, format: :js
          expect(response).not_to be_successful
          expect(response.body).to eq(I18n.t("javascripts.conversation.create.no_recipient"))
        end
      end

      context "with non-mutual contact" do
        let(:person1) { FactoryGirl.create(:person) }
        let(:person2) { FactoryGirl.create(:person) }
        let(:person3) { FactoryGirl.create(:person) }
        let(:params) {
          {
            conversation: {subject: "secret stuff", text: "text debug"},
            person_ids:   [person1.id, person2.id, person3.id].join(",")
          }
        }

        before do
          alice.contacts.create!(receiving: false, sharing: true, person: person2)
          alice.contacts.create!(receiving: true, sharing: false, person: person3)
        end

        it "does not create a conversation" do
          expect { post :create, params: params, format: :js }.not_to change(Conversation, :count)
        end

        it "does not create a message" do
          expect { post :create, params: params, format: :js }.not_to change(Message, :count)
        end

        it "responds with an error message" do
          post :create, params: params, format: :js
          expect(response).not_to be_successful
          expect(response.body).to eq(I18n.t("javascripts.conversation.create.no_recipient"))
        end
      end
    end

    context "mobile" do
      before do
        controller.session[:mobile_view] = true
      end

      context "with a valid conversation" do
        let(:params) {
          {
            conversation: {subject: "secret stuff", text: "text debug"},
            contact_ids:  alice.contacts.first.id.to_s
          }
        }

        it "creates a conversation" do
          expect { post :create, params: params, format: :js }.to change(Conversation, :count).by(1)
        end

        it "creates a message" do
          expect { post :create, params: params, format: :js }.to change(Message, :count).by(1)
        end

        it "responds with the conversation id as JSON" do
          post :create, params: params, format: :js
          expect(response).to be_successful
          expect(JSON.parse(response.body)["id"]).to eq(Conversation.first.id)
        end

        it "sets the author to the current_user" do
          params[:author] = FactoryGirl.create(:user)
          post :create, params: params, format: :js
          expect(Message.first.author).to eq(alice.person)
          expect(Conversation.first.author).to eq(alice.person)
        end

        it "dispatches the conversation" do
          Conversation.create(author: alice.person, participant_ids: [alice.contacts.first.person.id, alice.person.id],
                              subject: "not spam", messages_attributes: [{author: alice.person, text: "cool stuff"}])

          expect(Diaspora::Federation::Dispatcher).to receive(:defer_dispatch)
          post :create, params: params, format: :js
        end
      end

      context "with empty subject" do
        let(:params) {
          {
            conversation: {subject: " ", text: "text debug"},
            contact_ids:  alice.contacts.first.id.to_s
          }
        }

        it "creates a conversation" do
          expect { post :create, params: params, format: :js }.to change(Conversation, :count).by(1)
        end

        it "creates a message" do
          expect { post :create, params: params, format: :js }.to change(Message, :count).by(1)
        end

        it "responds with the conversation id as JSON" do
          post :create, params: params, format: :js
          expect(response).to be_successful
          expect(JSON.parse(response.body)["id"]).to eq(Conversation.first.id)
        end
      end

      context "with empty text" do
        let(:params) {
          {
            conversation: {subject: "secret stuff", text: " "},
            contact_ids:  alice.contacts.first.id.to_s
          }
        }

        it "does not create a conversation" do
          expect { post :create, params: params, format: :js }.not_to change(Conversation, :count)
        end

        it "does not create a message" do
          expect { post :create, params: params, format: :js }.not_to change(Message, :count)
        end

        it "responds with an error message" do
          post :create, params: params, format: :js
          expect(response).not_to be_successful
          expect(response.body).to eq(I18n.t("conversations.create.fail"))
        end
      end

      context "with empty contact" do
        let(:params) {
          {
            conversation: {subject: "secret stuff", text: "text debug"},
            contact_ids:  " "
          }
        }

        it "does not create a conversation" do
          expect { post :create, params: params, format: :js }.not_to change(Conversation, :count)
        end

        it "does not create a message" do
          expect { post :create, params: params, format: :js }.not_to change(Message, :count)
        end

        it "responds with an error message" do
          post :create, params: params, format: :js
          expect(response).not_to be_successful
          expect(response.body).to eq(I18n.t("javascripts.conversation.create.no_recipient"))
        end
      end

      context "with nil contact" do
        let(:params) {
          {
            conversation: {subject: "secret stuff", text: "text debug"},
            contact_ids:  nil
          }
        }

        it "does not create a conversation" do
          expect { post :create, params: params, format: :js }.not_to change(Conversation, :count)
        end

        it "does not create a message" do
          expect { post :create, params: params, format: :js }.not_to change(Message, :count)
        end

        it "responds with an error message" do
          post :create, params: params, format: :js
          expect(response).not_to be_successful
          expect(response.body).to eq(I18n.t("javascripts.conversation.create.no_recipient"))
        end
      end

      context "with non-mutual contact" do
        let(:contact1) { alice.contacts.create(receiving: false, sharing: true, person: FactoryGirl.create(:person)) }
        let(:contact2) { alice.contacts.create(receiving: true, sharing: false, person: FactoryGirl.create(:person)) }
        let(:params) {
          {
            conversation: {subject: "secret stuff", text: "text debug"},
            contact_ids:  [contact1.id, contact2.id].join(",")
          }
        }

        it "does not create a conversation" do
          expect { post :create, params: params, format: :js }.not_to change(Conversation, :count)
        end

        it "does not create a message" do
          expect { post :create, params: params, format: :js }.not_to change(Message, :count)
        end

        it "responds with an error message" do
          post :create, params: params, format: :js
          expect(response).not_to be_successful
          expect(response.body).to eq(I18n.t("javascripts.conversation.create.no_recipient"))
        end
      end
    end
  end

  describe "#show" do
    let(:conversation) {
      Conversation.create(
        author:              alice.person,
        participant_ids:     [alice.contacts.first.person.id, alice.person.id],
        subject:             "not spam",
        messages_attributes: [{author: alice.person, text: "cool stuff"}]
      )
    }

    it "succeeds with json" do
      get :show, params: {id: conversation.id}, format: :json
      expect(response).to be_successful
      expect(assigns[:conversation]).to eq(conversation)
      expect(response.body).to include conversation.guid
    end

    it "redirects to index" do
      get :show, params: {id: conversation.id}
      expect(response).to redirect_to(conversations_path(conversation_id: conversation.id))
    end
  end

  describe "#raw" do
    let(:conversation) {
      Conversation.create(
        author:              alice.person,
        participant_ids:     [alice.contacts.first.person.id, alice.person.id],
        subject:             "not spam",
        messages_attributes: [{author: alice.person, text: "cool stuff"}]
      )
    }

    it "returns html of conversation" do
      get :raw, params: {conversation_id: conversation.id}
      expect(response).to render_template(partial: "conversations/_show")
      expect(response.body).to include conversation.subject
      expect(response.body).to include conversation.messages.first.text
    end

    it "returns 404 when requesting non-existant conversation" do
      get :raw, params: {conversation_id: -1}
      expect(response).to have_http_status(404)
    end
  end
end
