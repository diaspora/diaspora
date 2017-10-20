# frozen_string_literal: true

describe ConversationsController, :type => :controller do
  describe '#index' do
    before do
      @person = alice.contacts.first.person
      hash = {
        :author => @person,
        :participant_ids => [alice.person.id, @person.id],
        :subject => 'not spam',
        :messages_attributes => [ {:author => @person, :text => 'cool stuff'} ]
      }
      @conv1 = Conversation.create(hash)
      Message.create(:author => @person, :created_at => Time.now + 100, :text => "message", :conversation_id => @conv1.id)
             .increase_unread(alice)
      Message.create(:author => @person, :created_at => Time.now + 200, :text => "another message", :conversation_id => @conv1.id)
             .increase_unread(alice)

      @conv2 = Conversation.create(hash)
      Message.create(:author => @person, :created_at => Time.now + 100, :text => "message", :conversation_id => @conv2.id)
             .increase_unread(alice)

      sign_in alice, scope: :user
    end

    it "generates a jasmine fixture", :fixture => true do
      get :index, params: {conversation_id: @conv1.id}
      save_fixture(html_for("body"), "conversations_unread")

      get :index, params: {conversation_id: @conv1.id}
      save_fixture(html_for("body"), "conversations_read")
    end
  end

  describe "#new" do
    before do
      sign_in alice, scope: :user
    end

    it "generates a jasmine fixture", fixture: true do
      session[:mobile_view] = true
      get :new, format: :mobile
      save_fixture(html_for("body"), "conversations_new_mobile")
    end
  end
end
