# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe TagsController, :type => :controller do
  describe '#index (search)' do
    before do
      sign_in alice, scope: :user
      bob.profile.tag_string = "#cats #diaspora #rad"
      bob.profile.build_tags
      bob.profile.save!
    end

    it 'responds with json' do
      get :index, params: {q: "ra"}, format: :json
      #parse json
      expect(response.body).to include("#rad")
    end

    it 'requires at least two characters' do
      get :index, params: {q: "c"}, format: :json
      expect(response.body).not_to include("#cats")
    end

    it 'redirects the aimless to excellent parties' do
      get :index
      expect(response).to redirect_to tag_path('partytimeexcellent')
    end

    it 'does not allow json requestors to party' do
      get :index, format: :json
      expect(response.status).to eq(422)
    end
  end

  describe '#show' do
    context 'tag with capital letters' do
      before do
        sign_in alice, scope: :user
      end

      it 'redirect to the downcase tag uri' do
        get :show, params: {name: "DiasporaRocks!"}
        expect(response).to redirect_to(:action => :show, :name => 'diasporarocks!')
      end
    end

    context 'with a tagged user' do
      before do
        bob.profile.tag_string = "#cats #diaspora #rad"
        bob.profile.build_tags
        bob.profile.save!
      end

      it 'includes the tagged user' do
        get :show, params: {name: "cats"}
        expect(response.body).to include(bob.diaspora_handle)
      end
    end

    context 'with a tagged post' do
      before do
        @post = eve.post(:status_message, text: "#what #yes #hellyes #foo tagged post", public: true, to: 'all')
      end

      context 'signed in' do
        before do
          sign_in alice, scope: :user
        end

        it 'assigns a Stream::Tag object with the current_user' do
          get :show, params: {name: "yes"}
          expect(assigns[:stream].user).to eq(alice)
        end

        it 'succeeds' do
          get :show, params: {name: "hellyes"}
          expect(response.status).to eq(200)
        end

        it 'includes the tagged post' do
          get :show, params: {name: "foo"}
          expect(assigns[:stream].posts.first.text).to include("tagged post")
        end

        it 'includes comments of the tagged post' do
          alice.comment!(@post, "comment on a tagged post")
          get :show, params: {name: "foo"}, format: :json
          expect(response.body).to include("comment on a tagged post")
        end
      end

      context "not signed in" do
        it 'assigns a Stream::Tag object with no user' do
          get :show, params: {name: "yes"}
          expect(assigns[:stream].user).to be_nil
        end

        it 'succeeds' do
          get :show, params: {name: "hellyes"}
          expect(response.status).to eq(200)
        end

        it 'succeeds with mobile' do
          get :show, params: {name: "foo"}, format: :mobile
          expect(response).to be_successful
        end

        it "returns the post with the correct age" do
          post2 = eve.post(
            :status_message,
            text:       "#what #yes #hellyes #foo tagged second post",
            public:     true,
            created_at: @post.created_at - 1.day
          )
          get :show, params: {name: "what", max_time: @post.created_at.to_i}, format: :json
          expect(JSON.parse(response.body).size).to be(1)
          expect(JSON.parse(response.body).first["guid"]).to eq(post2.guid)
        end
      end

      it "includes the correct meta tags" do
        tag_url = tag_url "yes", host: AppConfig.pod_uri.host, port: AppConfig.pod_uri.port

        get :show, params: {name: "yes"}

        expect(response.body).to include('<meta name="keywords" content="yes" />')
        expect(response.body).to include(
          %(<meta property="og:url" content="#{tag_url}" />)
        )
        expect(response.body).to include(
          '<meta property="og:title" content="#yes" />'
        )
        expect(response.body).to include(
          %(<meta name="description" content="#{I18n.t('streams.tags.title', tags: 'yes')}" />)
        )
        expect(response.body).to include(
          %(<meta property="og:description" content=\"#{I18n.t('streams.tags.title', tags: 'yes')}" />)
        )
      end
    end
  end

  context 'helper methods' do
    describe 'tag_followed?' do
      before do
        sign_in bob
        @tag = ActsAsTaggableOn::Tag.create!(:name => "partytimeexcellent")
        allow(@controller).to receive(:current_user).and_return(bob)
        allow(@controller).to receive(:params).and_return({:name => "PARTYTIMEexcellent"})
      end

      it 'returns true if the following already exists and should be case insensitive' do
        TagFollowing.create!(:tag => @tag, :user => bob )
        expect(@controller.send(:tag_followed?)).to be true
      end

      it 'returns false if the following does not already exist' do
        expect(@controller.send(:tag_followed?)).to be false
      end
    end
  end
end
