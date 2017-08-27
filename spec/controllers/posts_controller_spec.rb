# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe PostsController, type: :controller do
  let(:post) { alice.post(:status_message, text: "ohai", to: alice.aspects.first) }
  let(:post_service) { controller.send(:post_service) }

  describe "#show" do
    context "user signed in" do
      context "given a post that the user is allowed to see" do
        before do
          sign_in alice, scope: :user
        end

        it "succeeds" do
          expect_any_instance_of(PostService).to receive(:mark_user_notifications).with(post.id)

          get :show, params: {id: post.id}
          expect(response).to be_success
        end

        it "succeeds after removing a mention when closing the mentioned user's account" do
          user = FactoryGirl.create(:user, username: "user")
          alice.share_with(user.person, alice.aspects.first)

          msg = alice.post(:status_message, text: "Mention @{User ; #{user.diaspora_handle}}", public: true)

          expect(msg.mentioned_people.count).to eq(1)
          user.destroy

          get :show, params: {id: msg.id}
          expect(response).to be_success
        end

        it "renders the application layout on mobile" do
          get :show, params: {id: post.id}, format: :mobile
          expect(response).to render_template("layouts/application")
        end

        it "succeeds on mobile with a reshare" do
          reshare_id = FactoryGirl.create(:reshare, author: alice.person).id
          expect_any_instance_of(PostService).to receive(:mark_user_notifications).with(reshare_id)

          get :show, params: {id: reshare_id}, format: :mobile
          expect(response).to be_success
        end
      end

      context "given a post that the user is not allowed to see" do
        before do
          sign_in eve, scope: :user
        end

        it "returns a 404" do
          expect {
            get :show, params: {id: post.id}
          }.to raise_error ActiveRecord::RecordNotFound
        end
      end
    end

    context "user not signed in" do
      context "given a public post" do
        let(:public) { alice.post(:status_message, text: "hello", public: true) }
        let(:public_with_tags) { alice.post(:status_message, text: "#hi #howareyou", public: true) }

        it "shows a public post" do
          get :show, params: {id: public.id}
          expect(response.body).to match "hello"
        end

        it "succeeds for statusnet" do
          @request.env["HTTP_ACCEPT"] = "application/html+xml,text/html"
          get :show, params: {id: public.id}
          expect(response.body).to match "hello"
        end

        it "includes the correct uniques meta tags" do
          presenter = PostPresenter.new(public)
          methods_properties = {
            comma_separated_tags:   {html_attribute: "name",     name: "keywords"},
            description:            {html_attribute: "name",     name: "description"},
            url:                    {html_attribute: "property", name: "og:url"},
            title:                  {html_attribute: "property", name: "og:title"},
            published_time_iso8601: {html_attribute: "property", name: "og:article:published_time"},
            modified_time_iso8601:  {html_attribute: "property", name: "og:article:modified_time"},
            author_name:            {html_attribute: "property", name: "og:article:author"}
          }

          get :show, params: {id: public.id}, format: :html

          methods_properties.each do |method, property|
            value = presenter.send(method)
            expect(response.body).to include(
              "<meta #{property[:html_attribute]}=\"#{property[:name]}\" content=\"#{value}\" />"
            )
          end
        end

        it "includes the correct multiple meta tags" do
          get :show, params: {id: public_with_tags.id}, format: :html

          expect(response.body).to include('<meta property="og:article:tag" content="hi" />')
          expect(response.body).to include('<meta property="og:article:tag" content="howareyou" />')
        end
      end

      context "given a limited post" do
        it "forces the user to sign" do
          get :show, params: {id: post.id}
          expect(response).to be_redirect
          expect(response).to redirect_to new_user_session_path
        end
      end
    end
  end

  describe "oembed" do
    it "works when you can see it" do
      sign_in alice
      get :oembed, params: {url: "/posts/#{post.id}"}
      expect(response.body).to match /iframe/
    end

    it "returns a 404 response when the post is not found" do
      get :oembed, params: {url: "/posts/#{post.id}"}
      expect(response.status).to eq(404)
    end
  end

  describe "#mentionable" do
    context "with a user signed in" do
      before do
        sign_in alice
      end

      it "returns status 204 without a :q parameter" do
        get :mentionable, params: {id: post.id}, format: :json
        expect(response.status).to eq(204)
      end

      it "responses status 406 (not acceptable) on html request" do
        get :mentionable, params: {id: post.id, q: "whatever"}, format: :html
        expect(response.status).to eq(406)
      end

      it "responses status 404 when the post can't be found" do
        expect(post_service).to receive(:find!) do
          raise ActiveRecord::RecordNotFound
        end
        get :mentionable, params: {id: post.id, q: "whatever"}, format: :json
        expect(response.status).to eq(404)
      end

      it "calls PostService#mentionable_in_comment and passes the result as a response" do
        expect(post_service).to receive(:mentionable_in_comment).with(post.id.to_s, "whatever").and_return([bob.person])
        get :mentionable, params: {id: post.id, q: "whatever"}, format: :json
        expect(response.status).to eq(200)
        expect(response.body).to eq([bob.person].to_json)
      end
    end

    context "without a user signed in" do
      it "returns 401" do
        allow(post_service).to receive(:mentionable_in_comment).and_return([])
        get :mentionable, params: {id: post.id, q: "whatever"}, format: :json
        expect(response.status).to eq(401)
        expect(JSON.parse(response.body)["error"]).to eq(I18n.t("devise.failure.unauthenticated"))
      end
    end
  end

  describe "#destroy" do
    context "own post" do
      before do
        sign_in alice
      end

      it "works when it is your post" do
        expect_any_instance_of(PostService).to receive(:destroy).with(post.id.to_s)

        delete :destroy, params: {id: post.id}, format: :json
        expect(response.status).to eq(204)
      end

      it "redirects to stream on mobile" do
        delete :destroy, params: {id: post.id}, format: :mobile
        expect(response).to be_redirect
        expect(response).to redirect_to stream_path
      end
    end

    context "post of another user" do
      it "will respond with a 403" do
        sign_in bob, scope: :user

        delete :destroy, params: {id: post.id}, format: :json
        expect(response.body).to eq("You are not allowed to do that")
        expect(response.status).to eq(403)
      end

      it "will respond with a 404 if the post is not visible" do
        sign_in eve, scope: :user

        expect {
          delete :destroy, params: {id: post.id}, format: :json
        }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end
