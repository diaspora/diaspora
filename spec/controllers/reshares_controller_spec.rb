require 'spec_helper'

describe ResharesController, :type => :controller do
  describe '#create' do
    let(:post_request!) {
      post :create, :format => :json, :root_guid => @post_guid
    }

    before do
      @post = FactoryGirl.create(:status_message, :public => true)
      @post_guid = @post.guid
    end

    it 'requires authentication' do
      post_request!
      expect(response).not_to be_success
    end

    context 'with an authenticated user' do
      before do
        sign_in :user, bob
        allow(@controller).to receive(:current_user).and_return(bob)
      end

      it 'succeeds' do
        expect(response).to be_success
        post_request!
      end

      it 'creates a reshare' do
        expect{
          post_request!
        }.to change(Reshare, :count).by(1)
      end

      it 'after save, calls add to streams' do
        expect(bob).to receive(:add_to_streams)
        post_request!
      end

      it 'calls dispatch' do
        expect(bob).to receive(:dispatch_post).with(anything, hash_including(:additional_subscribers))
        post_request!
      end

      context 'resharing a reshared post' do
        before do
          FactoryGirl.create(:reshare, :root => @post, :author => bob.person)
        end

        it 'doesn\'t allow the user to reshare the post again' do
          post_request!
          expect(response.code).to eq('422')
          expect(response.body.strip).to be_empty
        end
      end

      context 'resharing another user\'s reshare' do
        before do
          @root = @post
          @post = FactoryGirl.create(:reshare, :root => @root, :author => alice.person)
        end

        it 'reshares the absolute root' do
          post_request!
          expect(@post.reshares.count).to eq(0)
          expect(@root.reshares.count).to eq(2)
        end
      end
    end
  end
end
