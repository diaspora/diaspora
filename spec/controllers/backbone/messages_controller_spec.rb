
require 'spec_helper'

describe Backbone::MessagesController do
  before do
    request.accept = Mime::BACKBONE
  end

  describe '#index' do
    before do
      @c_no_msg = FactoryGirl.create(:conversation, author: bob.person)
      @conv     = FactoryGirl.create(:conversation_with_message, author: alice.person)
    end

    it "responds with 404 if conversation wasn't found" do
      sign_in :user, eve
      get :index, conversation_id: @conv.id

      expect(response).not_to be_success
      response.status.should eql 404
    end

    it "returns an empty array if the conversation has no messages" do
      sign_in :user, bob
      get :index, conversation_id: @c_no_msg.id

      expect(response).to be_success
      parse_json(response.body).should eql []
    end

    it "returns the messages as json" do
      sign_in :user, alice
      get :index, conversation_id: @conv.id

      expect(response).to be_success
      parse_json(response.body).map { |m| m[:id] }.should include(*@conv.messages.pluck(:id))
    end
  end

  describe '#create' do
    before do
      @conv = FactoryGirl.create(:conversation, author: eve.person)
      @msg_txt = "testing texting message text"
      @create_hash = { message: { text: @msg_txt } }
    end

    it "responds with 404 if conversation wasn't found" do
      sign_in :user, alice
      post :create, @create_hash.merge(conversation_id: 0)

      expect(response).not_to be_success
      response.status.should eql 404
    end

    it "fails for invalid params" do
      sign_in :user, eve
      post :create, { not_a_message: true }.merge(conversation_id: @conv.id)

      expect(response).not_to be_success
      response.status.should eql 400
    end

    it "creates a message on one's own conversation" do
      sign_in :user, eve
      post :create, @create_hash.merge(conversation_id: @conv.id)

      expect(response).to be_success
      return_obj = parse_json(response.body)
      return_obj[:text].should eql @msg_txt
      return_obj[:author][:id].should eql eve.person_id
    end

    it "dispatches the message" do
      @controller.stub(:current_user).and_return(eve)
      sign_in :user, eve
      eve.should_receive(:dispatch)
      post :create, @create_hash.merge(conversation_id: @conv.id)
    end

    context 'different user' do
      before do
        @conv.participants << bob.person
        @conv.save

        @msg_txt_bob = @msg_txt + " by bob"
      end

      it "creates a message on someone else's conversation" do
        sign_in :user, bob
        @create_hash[:message][:text] = @msg_txt_bob

        lambda {
          post :create, @create_hash.merge(conversation_id: @conv.id)
        }.should change(@conv.messages, :count).by(1)
        expect(response).to be_success
        return_obj = parse_json(response.body)
        return_obj[:text].should eql @msg_txt_bob
        return_obj[:author][:id].should eql bob.person_id
      end
    end
  end
end
