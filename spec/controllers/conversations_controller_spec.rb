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
        get :new, modal: true
        expect(response).to be_success
      end

      it "assigns a contact if passed a contact id" do
        get :new, contact_id: alice.contacts.first.id, modal: true
        expect(controller.gon.conversation_prefill).to eq([alice.contacts.first.person.as_json])
      end

      it "assigns a set of contacts if passed an aspect id" do
        get :new, aspect_id: alice.aspects.first.id, modal: true
        expect(controller.gon.conversation_prefill).to eq(alice.aspects.first.contacts.map {|c| c.person.as_json })
      end
    end

    context "mobile" do
      before do
        controller.session[:mobile_view] = true
      end

      it "assigns a json list of contacts that are sharing with the person" do
        sharing_user = FactoryGirl.create(:user_with_aspect)
        sharing_user.share_with(alice.person, sharing_user.aspects.first)
        get :new, modal: true
        expect(assigns(:contacts_json))
          .to include(alice.contacts.where(sharing: true, receiving: true).first.person.name)
        alice.contacts << Contact.new(person_id: eve.person.id, user_id: alice.id, sharing: false, receiving: true)
        expect(assigns(:contacts_json)).not_to include(alice.contacts.where(sharing: false).first.person.name)
        expect(assigns(:contacts_json)).not_to include(alice.contacts.where(receiving: false).first.person.name)
      end

      it "does not allow XSS via the name parameter" do
        ["</script><script>alert(1);</script>",
         '"}]});alert(1);(function f() {var foo = [{b:"'].each do |xss|
          get :new, modal: true, name: xss
          expect(response.body).not_to include xss
        end
      end

      it "does not allow XSS via the profile name" do
        xss     = "<script>alert(0);</script>"
        contact = alice.contacts.first
        contact.person.profile.update_attribute(:first_name, xss)
        get :new, modal: true
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
      expect(response).to be_success
      expect(assigns[:visibilities]).to match_array(@visibilities)
    end

    it "succeeds with json" do
      get :index, format: :json
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json.first["conversation"]).to be_present
    end

    it "retrieves all conversations for a user" do
      get :index
      expect(assigns[:visibilities].count).to eq(3)
    end

    it "retrieves a conversation" do
      get :index, conversation_id: @conversations.first.id
      expect(response).to be_success
      expect(assigns[:visibilities]).to match_array(@visibilities)
      expect(assigns[:conversation]).to eq(@conversations.first)
    end

    it "does not let you access conversations where you are not a recipient" do
      sign_in eve, scope: :user
      get :index, conversation_id: @conversations.first.id
      expect(assigns[:conversation]).to be_nil
    end

    it "retrieves a conversation message with out markdown content " do
      get :index
      @conversation = @conversations.first
      expect(response).to be_success
      expect(response.body).to match(/cool stuff/)
      expect(response.body).not_to match(%r{<strong>cool stuff</strong>})
    end
  end

  describe "#create" do
    context "desktop" do
      context "with a valid conversation" do
        before do
          @hash = {
            format:       :js,
            conversation: {subject: "secret stuff", text: "text debug"},
            person_ids:   alice.contacts.first.person.id.to_s
          }
        end

        it "creates a conversation" do
          expect { post :create, @hash }.to change(Conversation, :count).by(1)
        end

        it "creates a message" do
          expect { post :create, @hash }.to change(Message, :count).by(1)
        end

        it "responds with the conversation id as JSON" do
          post :create, @hash
          expect(response).to be_success
          expect(JSON.parse(response.body)["id"]).to eq(Conversation.first.id)
        end

        it "sets the author to the current_user" do
          @hash[:author] = FactoryGirl.create(:user)
          post :create, @hash
          expect(Message.first.author).to eq(alice.person)
          expect(Conversation.first.author).to eq(alice.person)
        end

        it "dispatches the conversation" do
          Conversation.create(author:  alice.person, participant_ids: [alice.contacts.first.person.id, alice.person.id],
                              subject: "not spam", messages_attributes: [{author: alice.person, text: "cool stuff"}])

          expect(Diaspora::Federation::Dispatcher).to receive(:defer_dispatch)
          post :create, @hash
        end
      end

      context "with empty subject" do
        before do
          @hash = {
            format:       :js,
            conversation: {subject: " ", text: "text debug"},
            person_ids:   alice.contacts.first.person.id.to_s
          }
        end

        it "creates a conversation" do
          expect { post :create, @hash }.to change(Conversation, :count).by(1)
        end

        it "creates a message" do
          expect { post :create, @hash }.to change(Message, :count).by(1)
        end

        it "responds with the conversation id as JSON" do
          post :create, @hash
          expect(response).to be_success
          expect(JSON.parse(response.body)["id"]).to eq(Conversation.first.id)
        end
      end

      context "with empty text" do
        before do
          @hash = {
            format:       :js,
            conversation: {subject: "secret stuff", text: "  "},
            person_ids:   alice.contacts.first.person.id.to_s
          }
        end

        it "does not create a conversation" do
          expect { post :create, @hash }.not_to change(Conversation, :count)
        end

        it "does not create a message" do
          expect { post :create, @hash }.not_to change(Message, :count)
        end

        it "responds with an error message" do
          post :create, @hash
          expect(response).not_to be_success
          expect(response.body).to eq(I18n.t("conversations.create.fail"))
        end
      end

      context "with empty contact" do
        before do
          @hash = {
            format:       :js,
            conversation: {subject: "secret stuff", text: "text debug"},
            person_ids:   " "
          }
        end

        it "does not create a conversation" do
          expect { post :create, @hash }.not_to change(Conversation, :count)
        end

        it "does not create a message" do
          expect { post :create, @hash }.not_to change(Message, :count)
        end

        it "responds with an error message" do
          post :create, @hash
          expect(response).not_to be_success
          expect(response.body).to eq(I18n.t("javascripts.conversation.create.no_recipient"))
        end
      end

      context "with nil contact" do
        before do
          @hash = {
            format:       :js,
            conversation: {subject: "secret stuff", text: "text debug"},
            person_ids:   nil
          }
        end

        it "does not create a conversation" do
          expect { post :create, @hash }.not_to change(Conversation, :count)
        end

        it "does not create a message" do
          expect { post :create, @hash }.not_to change(Message, :count)
        end

        it "responds with an error message" do
          post :create, @hash
          expect(response).not_to be_success
          expect(response.body).to eq(I18n.t("javascripts.conversation.create.no_recipient"))
        end
      end

      context "with non-mutual contact" do
        before do
          @person1 = FactoryGirl.create(:person)
          @person2 = FactoryGirl.create(:person)
          alice.contacts.create!(receiving: false, sharing: true, person: @person2)
          @person3 = FactoryGirl.create(:person)
          alice.contacts.create!(receiving: true, sharing: false, person: @person3)
          @hash = {
            format:       :js,
            conversation: {subject: "secret stuff", text: "text debug"},
            person_ids:   [@person1.id, @person2.id, @person3.id].join(",")
          }
        end

        it "does not create a conversation" do
          expect { post :create, @hash }.not_to change(Conversation, :count)
        end

        it "does not create a message" do
          expect { post :create, @hash }.not_to change(Message, :count)
        end

        it "responds with an error message" do
          post :create, @hash
          expect(response).not_to be_success
          expect(response.body).to eq(I18n.t("javascripts.conversation.create.no_recipient"))
        end
      end
    end

    context "mobile" do
      before do
        controller.session[:mobile_view] = true
      end

      context "with a valid conversation" do
        before do
          @hash = {
            format:       :js,
            conversation: {subject: "secret stuff", text: "text debug"},
            contact_ids:  alice.contacts.first.id.to_s
          }
        end

        it "creates a conversation" do
          expect { post :create, @hash }.to change(Conversation, :count).by(1)
        end

        it "creates a message" do
          expect { post :create, @hash }.to change(Message, :count).by(1)
        end

        it "responds with the conversation id as JSON" do
          post :create, @hash
          expect(response).to be_success
          expect(JSON.parse(response.body)["id"]).to eq(Conversation.first.id)
        end

        it "sets the author to the current_user" do
          @hash[:author] = FactoryGirl.create(:user)
          post :create, @hash
          expect(Message.first.author).to eq(alice.person)
          expect(Conversation.first.author).to eq(alice.person)
        end

        it "dispatches the conversation" do
          Conversation.create(author: alice.person, participant_ids: [alice.contacts.first.person.id, alice.person.id],
                              subject: "not spam", messages_attributes: [{author: alice.person, text: "cool stuff"}])

          expect(Diaspora::Federation::Dispatcher).to receive(:defer_dispatch)
          post :create, @hash
        end
      end

      context "with empty subject" do
        before do
          @hash = {
            format:       :js,
            conversation: {subject: " ", text: "text debug"},
            contact_ids:  alice.contacts.first.id.to_s
          }
        end

        it "creates a conversation" do
          expect { post :create, @hash }.to change(Conversation, :count).by(1)
        end

        it "creates a message" do
          expect { post :create, @hash }.to change(Message, :count).by(1)
        end

        it "responds with the conversation id as JSON" do
          post :create, @hash
          expect(response).to be_success
          expect(JSON.parse(response.body)["id"]).to eq(Conversation.first.id)
        end
      end

      context "with empty text" do
        before do
          @hash = {
            format:       :js,
            conversation: {subject: "secret stuff", text: " "},
            contact_ids:  alice.contacts.first.id.to_s
          }
        end

        it "does not create a conversation" do
          expect { post :create, @hash }.not_to change(Conversation, :count)
        end

        it "does not create a message" do
          expect { post :create, @hash }.not_to change(Message, :count)
        end

        it "responds with an error message" do
          post :create, @hash
          expect(response).not_to be_success
          expect(response.body).to eq(I18n.t("conversations.create.fail"))
        end
      end

      context "with empty contact" do
        before do
          @hash = {
            format:       :js,
            conversation: {subject: "secret stuff", text: "text debug"},
            contact_ids:  " "
          }
        end

        it "does not create a conversation" do
          expect { post :create, @hash }.not_to change(Conversation, :count)
        end

        it "does not create a message" do
          expect { post :create, @hash }.not_to change(Message, :count)
        end

        it "responds with an error message" do
          post :create, @hash
          expect(response).not_to be_success
          expect(response.body).to eq(I18n.t("javascripts.conversation.create.no_recipient"))
        end
      end

      context "with nil contact" do
        before do
          @hash = {
            format:       :js,
            conversation: {subject: "secret stuff", text: "text debug"},
            contact_ids:  nil
          }
        end

        it "does not create a conversation" do
          expect { post :create, @hash }.not_to change(Conversation, :count)
        end

        it "does not create a message" do
          expect { post :create, @hash }.not_to change(Message, :count)
        end

        it "responds with an error message" do
          post :create, @hash
          expect(response).not_to be_success
          expect(response.body).to eq(I18n.t("javascripts.conversation.create.no_recipient"))
        end
      end

      context "with non-mutual contact" do
        before do
          @contact1 = alice.contacts.create(receiving: false, sharing: true, person: FactoryGirl.create(:person))
          @contact2 = alice.contacts.create(receiving: true, sharing: false, person: FactoryGirl.create(:person))
          @hash = {
            format:       :js,
            conversation: {subject: "secret stuff", text: "text debug"},
            person_ids:   [@contact1.id, @contact2.id].join(",")
          }
        end

        it "does not create a conversation" do
          expect { post :create, @hash }.not_to change(Conversation, :count)
        end

        it "does not create a message" do
          expect { post :create, @hash }.not_to change(Message, :count)
        end

        it "responds with an error message" do
          post :create, @hash
          expect(response).not_to be_success
          expect(response.body).to eq(I18n.t("javascripts.conversation.create.no_recipient"))
        end
      end
    end
  end

  describe "#show" do
    before do
      hash = {
        author:              alice.person,
        participant_ids:     [alice.contacts.first.person.id, alice.person.id],
        subject:             "not spam",
        messages_attributes: [{author: alice.person, text: "cool stuff"}]
      }
      @conversation = Conversation.create(hash)
    end

    it "succeeds with json" do
      get :show, :id => @conversation.id, :format => :json
      expect(response).to be_success
      expect(assigns[:conversation]).to eq(@conversation)
      expect(response.body).to include @conversation.guid
    end

    it "redirects to index" do
      get :show, :id => @conversation.id
      expect(response).to redirect_to(conversations_path(:conversation_id => @conversation.id))
    end
  end

  describe "#raw" do
    before do
      hash = {
        author:              alice.person,
        participant_ids:     [alice.contacts.first.person.id, alice.person.id],
        subject:             "not spam",
        messages_attributes: [{author: alice.person, text: "cool stuff"}]
      }
      @conversation = Conversation.create(hash)
    end

    it "returns html of conversation" do
      get :raw, conversation_id: @conversation.id
      expect(response).to render_template(partial: "show", locals: {conversation: @conversation})
    end

    it "returns 404 when requesting non-existant conversation" do
      get :raw, conversation_id: -1
      expect(response).to have_http_status(404)
    end
  end
end
