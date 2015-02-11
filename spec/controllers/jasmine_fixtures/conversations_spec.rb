require 'spec_helper'

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

      sign_in :user, alice
    end

    it "generates a jasmine fixture", :fixture => true do
      get :index, :conversation_id => @conv1.id
      save_fixture(html_for("body"), "conversations_unread")

      get :index, :conversation_id => @conv1.id
      save_fixture(html_for("body"), "conversations_read")
    end
  end
end
