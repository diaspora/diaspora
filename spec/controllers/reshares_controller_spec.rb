require 'spec_helper'
describe ResharesController do

  describe '#create' do
    it 'requires authentication' do
      post :create, :format => :js
      response.should_not be_success
    end

    context 'with an authenticated user' do
      before do
        sign_in :user, bob
        @post_guid = Factory(:status_message, :public => true).guid
        @controller.stub(:current_user).and_return(bob)
      end

      it 'succeeds' do
        post :create, :format => :js, :root_guid => @post_guid
        response.should be_success
      end

      it 'creates a reshare' do
        expect{
          post :create, :format => :js, :root_guid => @post_guid
        }.should change(Reshare, :count).by(1)
      end

      it 'after save, calls add to streams' do
        bob.should_receive(:add_to_streams)
        post :create, :format => :js, :root_guid => @post_guid
      end

      it 'calls dispatch' do
        bob.should_receive(:dispatch_post).with(anything, hash_including(:additional_subscribers))
        post :create, :format => :js, :root_guid => @post_guid
      end
    end
  end
end
