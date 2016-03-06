#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require "spec_helper"

describe PostsController, type: :controller do
  let(:post) { alice.post(:status_message, text: "ohai", to: alice.aspects.first) }

  describe "#show" do
    context "user signed in" do
      context "given a post that the user is allowed to see" do
        before do
          sign_in :user, alice
        end

        it "succeeds" do
          expect_any_instance_of(PostService).to receive(:mark_user_notifications).with(post.id)

          get :show, id: post.id
          expect(response).to be_success
        end

        it "succeeds after removing a mention when closing the mentioned user's account" do
          user = FactoryGirl.create(:user, username: "user")
          alice.share_with(user.person, alice.aspects.first)

          msg = alice.post(:status_message, text: "Mention @{User ; #{user.diaspora_handle}}", public: true)

          expect(msg.mentioned_people.count).to eq(1)
          user.destroy

          get :show, id: msg.id
          expect(response).to be_success
        end

        it "renders the application layout on mobile" do
          get :show, id: post.id, format: :mobile
          expect(response).to render_template("layouts/application")
        end

        it "succeeds on mobile with a reshare" do
          reshare_id = FactoryGirl.create(:reshare, author: alice.person).id
          expect_any_instance_of(PostService).to receive(:mark_user_notifications).with(reshare_id)

          get :show, id: reshare_id, format: :mobile
          expect(response).to be_success
        end
      end

      context "given a post that the user is not allowed to see" do
        before do
          sign_in :user, eve
        end

        it "returns a 404" do
          expect {
            get :show, id: post.id
          }.to raise_error ActiveRecord::RecordNotFound
        end
      end
    end

    context "user not signed in" do
      context "given a public post" do
        let(:public) { alice.post(:status_message, text: "hello", public: true) }

        it "shows a public post" do
          get :show, id: public.id
          expect(response.body).to match "hello"
        end

        it "succeeds for statusnet" do
          @request.env["HTTP_ACCEPT"] = "application/html+xml,text/html"
          get :show, id: public.id
          expect(response.body).to match "hello"
        end

        it "responds with diaspora xml if format is xml" do
          get :show, id: public.guid, format: :xml
          expect(response.body).to eq(public.to_diaspora_xml)
        end
      end

      context "given a limited post" do
        it "forces the user to sign" do
          get :show, id: post.id
          expect(response).to be_redirect
          expect(response).to redirect_to new_user_session_path
        end
      end
    end
  end

  describe "oembed" do
    it "works when you can see it" do
      sign_in alice
      get :oembed, url: "/posts/#{post.id}"
      expect(response.body).to match /iframe/
    end

    it "returns a 404 response when the post is not found" do
      get :oembed, url: "/posts/#{post.id}"
      expect(response.status).to eq(404)
    end
  end

  describe "#destroy" do
    context "own post" do
      before do
        sign_in alice
      end

      it "works when it is your post" do
        expect_any_instance_of(PostService).to receive(:destroy).with(post.id.to_s)

        delete :destroy, format: :json, id: post.id
        expect(response.status).to eq(204)
      end

      it "redirects to stream on mobile" do
        delete :destroy, format: :mobile, id: post.id
        expect(response).to be_redirect
        expect(response).to redirect_to stream_path
      end
    end

    context "post of another user" do
      it "will respond with a 403" do
        sign_in :user, bob

        delete :destroy, format: :json, id: post.id
        expect(response.body).to eq("You are not allowed to do that")
        expect(response.status).to eq(403)
      end

      it "will respond with a 404 if the post is not visible" do
        sign_in :user, eve

        expect {
          delete :destroy, format: :json, id: post.id
        }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end
