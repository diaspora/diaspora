require 'spec_helper'

describe ResharesController do
  describe '#create' do
    let(:post_request!) {
      post :create, :format => :json, :root_guid => @post_guid
    }

    before do
      @post_guid = FactoryGirl.create(:status_message, :public => true).guid
    end

    it 'requires authentication' do
      post_request!
      response.should_not be_success
    end

    context 'with an authenticated user' do
      before do
        sign_in :user, bob
        @controller.stub(:current_user).and_return(bob)
      end

      it 'succeeds' do
        response.should be_success
        post_request!
      end

      it 'creates a reshare' do
        expect{
          post_request!
        }.to change(Reshare, :count).by(1)
      end

      it 'after save, calls add to streams' do
        bob.should_receive(:add_to_streams)
        post_request!
      end

      it 'calls dispatch' do
        bob.should_receive(:dispatch_post).with(anything, hash_including(:additional_subscribers))
        post_request!
      end
    end
  end
end
