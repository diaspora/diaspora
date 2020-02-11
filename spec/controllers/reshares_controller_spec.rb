# frozen_string_literal: true

describe ResharesController, :type => :controller do
  describe '#create' do
    let(:post_request!) {
      post :create, params: {root_guid: @post_guid}, format: :json
    }

    before do
      @post = FactoryGirl.create(:status_message, :public => true)
      @post_guid = @post.guid
    end

    it 'requires authentication' do
      post_request!
      expect(response).not_to be_successful
    end

    context 'with an authenticated user' do
      before do
        sign_in(bob, scope: :user)
        allow(@controller).to receive(:current_user).and_return(bob)
      end

      it 'succeeds' do
        expect(response).to be_successful
        post_request!
      end

      it 'creates a reshare' do
        expect{
          post_request!
        }.to change(Reshare, :count).by(1)
      end

      it "federates" do
        allow_any_instance_of(Participation::Generator).to receive(:create!)
        expect(Diaspora::Federation::Dispatcher).to receive(:defer_dispatch)
        post_request!
      end

      context 'resharing a reshared post' do
        before do
          FactoryGirl.create(:reshare, :root => @post, :author => bob.person)
        end

        it 'doesn\'t allow the user to reshare the post again' do
          post_request!
          expect(response.code).to eq('422')
          expect(response.body).to eq(I18n.t("reshares.create.error"))
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

  describe "#index" do
    context "with a private post" do
      before do
        @alices_aspect = alice.aspects.where(name: "generic").first
        @post = alice.post(:status_message, text: "hey", to: @alices_aspect.id)
      end

      it "returns a 404 for a post not visible to the user" do
        sign_in(eve, scope: :user)
        expect {
          get :index, params: {post_id: @post.id}, format: :json
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "returns an empty array for a post visible to the user" do
        sign_in(bob, scope: :user)
        get :index, params: {post_id: @post.id}, format: :json
        expect(JSON.parse(response.body)).to eq([])
      end
    end

    context "with a public post" do
      before do
        sign_in(alice, scope: :user)
        @post = alice.post(:status_message, text: "hey", public: true)
      end

      it "returns an array of reshares for a post" do
        bob.reshare!(@post)
        get :index, params: {post_id: @post.id}, format: :json
        expect(JSON.parse(response.body).map {|h| h["id"] }).to eq(@post.reshares.map(&:id))
      end

      it "returns an empty array for a post with no reshares" do
        get :index, params: {post_id: @post.id}, format: :json
        expect(JSON.parse(response.body)).to eq([])
      end

      it "returns reshares without login" do
        bob.reshare!(@post)
        sign_out :user
        get :index, params: {post_id: @post.id}, format: :json
        expect(JSON.parse(response.body).map {|h| h["id"] }).to match_array(@post.reshares.map(&:id))
      end
    end
  end
end
