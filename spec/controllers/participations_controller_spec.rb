# frozen_string_literal: true

describe ParticipationsController, :type => :controller do
  before do
    allow(@controller).to receive(:current_user).and_return(alice)
    sign_in alice, scope: :user
  end

  describe '#create' do
    let(:stranger) { FactoryGirl.create(:user) }

    shared_examples 'on a visible post' do
      it 'creates the participation' do
        post :create, params: {post_id: @post.id}
        expect(alice.participations.where(:target_id => @post.id)).to exist
        expect(response.code).to eq('201')
      end
    end

    context 'on my own post' do
      before do
        aspect_to_post = alice.aspects.where(:name => 'generic').first
        @post = alice.post :status_message, :text => 'something', :to => aspect_to_post
      end

      it_behaves_like 'on a visible post'
    end

    context 'on a post from a contact' do
      before do
        aspect_to_post = bob.aspects.where(:name => 'generic').first
        @post = bob.post :status_message, :text => 'something', :to => aspect_to_post
      end

      it_behaves_like 'on a visible post'
    end

    context 'on a public post from a stranger' do
      before do
        @post = stranger.post :status_message, :text => 'something', :public => true, :to => 'all'
      end

      it_behaves_like 'on a visible post'
    end

    context 'on a non visible post' do
      before do
        @post = stranger.post :status_message, :text => 'something', :public => false, :to => 'all'
      end

      it 'should not create the participation' do
        post :create, params: {post_id: @post.id}
        expect(alice.participations.where(:target_id => @post.id)).not_to exist
        expect(response.code).to eq('403')
      end
    end
  end

  describe '#destroy' do
    let(:post) { FactoryGirl.create(:status_message) }

    context 'on a post you partecipate to' do
      before { alice.participate! post }

      it 'should remove participation' do
        delete :destroy, params: {post_id: post.id}
        expect(alice.participations.where(:target_id => post.id)).not_to exist
        expect(response.code).to eq('200')
      end
    end

    context 'on a post you do not partecipate to' do
      it 'says it is an unprocessable request' do
        delete :destroy, params: {post_id: post.id}
        expect(response.code).to eq('422')
      end
    end
  end
end
