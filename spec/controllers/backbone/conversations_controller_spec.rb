
require 'spec_helper'

describe Backbone::ConversationsController do
  before do
    request.accept = Mime::BACKBONE

    @user_empty = FactoryGirl.create(:user)
    @user = FactoryGirl.create(:user)
    @c1 = FactoryGirl.create(:conversation, author: @user.person)
    @c2 = FactoryGirl.create(:conversation, author: @user.person)
  end

  describe '#index' do
    it 'returns an empty set if user has no conversations' do
      sign_in :user, @user_empty
      get :index
      expect(response).to be_success
      parse_json(response.body).should eql []
    end

    it 'returns the users conversations' do
      sign_in :user, @user
      get :index
      expect(response).to be_success
      parse_json(response.body).map { |c| c[:id] }.should include(@c1.id, @c2.id)
    end
  end

  describe '#create' do
    before do
      sign_in :user, alice

      @conv_subj = "test subject"
      @create_hash = {
        contact_ids: [alice.contacts.pluck(:id)],
        conversation: {
          subject: @conv_subj,
          text: "test text test text", # this is *not* the actual text
          message: {
            text: "asdf test asdf text" # this will be used
          }
        }
      }
    end

    it 'fails for invalid params' do
      post :create, {not_a_conversation: true}
      expect(response).not_to be_success
      response.status.should eql 400
    end

    it 'creates a conversation' do
      lambda {
        post :create, @create_hash
      }.should change(Conversation, :count).by(1)
      expect(response).to be_success
      return_obj = parse_json(response.body)
      return_obj[:subject].should eql @conv_subj
      return_obj[:author][:id].should eql alice.person_id
    end

    it 'creates a message' do
      lambda {
        post :create, @create_hash
      }.should change(Message, :count).by(1)
      expect(response).to be_success
    end

    it 'dispatches the conversation' do
      @controller.stub(:current_user).and_return(alice)
      alice.should_receive(:dispatch)

      post :create, @create_hash
      expect(response).to be_success
    end
  end
end
