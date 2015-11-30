#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require "spec_helper"

describe PostsController, type: :controller do
  let!(:post_service_double) { double("post_service") }

  before do
    aspect = alice.aspects.first
    @message = alice.build_post :status_message, text: "ohai", to: aspect.id
    @message.save!

    alice.add_to_streams(@message, [aspect])
    alice.dispatch_post @message, to: aspect.id

    allow(PostService).to receive(:new).and_return(post_service_double)
  end

  describe "#show" do
    before do
      expect(post_service_double).to receive(:mark_user_notifications)
      allow(post_service_double).to receive(:present_json)
    end

    context "user signed in" do
      context "given a post that the user is allowed to see" do
        before do
          sign_in :user, alice
          expect(post_service_double).to receive(:post).and_return(@message)
        end

        it "succeeds" do
          get :show, id: @message.id
          expect(response).to be_success
        end

        it 'succeeds after removing a mention when closing the mentioned user\'s account' do
          user = FactoryGirl.create(:user, username: "user")
          alice.share_with(user.person, alice.aspects.first)
          msg = alice.build_post :status_message,
                                 text: "Mention @{User ; #{user.diaspora_handle}}", public: true, to: "all"
          msg.save!
          expect(msg.mentioned_people.count).to eq(1)
          user.destroy
          get :show, id: msg.id
          expect(response).to be_success
        end

        it "renders the application layout on mobile" do
          get :show, id: @message.id, format: :mobile
          expect(response).to render_template("layouts/application")
        end

        it "succeeds on mobile with a reshare" do
          get :show, id: FactoryGirl.create(:reshare, author: alice.person).id, format: :mobile
          expect(response).to be_success
        end
      end

      context "given a post that the user is not allowed to see" do
        before do
          sign_in :user, alice
          expect(post_service_double).to receive(:post).and_raise(Diaspora::NonPublic)
        end

        it "returns a 404" do
          get :show, id: @message.id
          expect(response.code).to eq("404")
        end
      end
    end

    context "user not signed in" do
      context "given a public post" do
        before :each do
          @status = alice.post(:status_message, text: "hello", public: true, to: "all")
          expect(post_service_double).to receive(:post).and_return(@status)
        end

        it "shows a public post" do
          get :show, id: @status.id
          expect(response.body).to match "hello"
        end

        it "succeeds for statusnet" do
          @request.env["HTTP_ACCEPT"] = "application/html+xml,text/html"
          get :show, id: @status.id
          expect(response.body).to match "hello"
        end

        it "responds with diaspora xml if format is xml" do
          get :show, id: @status.guid, format: :xml
          expect(response.body).to eq(@status.to_diaspora_xml)
        end
      end

      context "given a limited post" do
        before do
          expect(post_service_double).to receive(:post).and_raise(Diaspora::NonPublic)
        end

        it "forces the user to sign" do
          get :show, id: @message.id
          expect(response).to be_redirect
          expect(response).to redirect_to new_user_session_path
        end
      end
    end
  end

  describe "iframe" do
    it "contains an iframe" do
      get :iframe, id: @message.id
      expect(response.body).to match /iframe/
    end
  end

  describe "oembed" do
    it "receives a present oembed" do
      expect(post_service_double).to receive(:present_oembed)
      get :oembed, url: "/posts/#{@message.id}"
    end
  end

  describe "#destroy" do
    before do
      sign_in alice
    end

    it "will receive a retract post" do
      expect(post_service_double).to receive(:retract_post)
      expect(post_service_double).to receive(:post).and_return(@message)
      message = alice.post(:status_message, text: "hey", to: alice.aspects.first.id)
      delete :destroy, format: :js, id: message.id
    end

    context "when Diaspora::NotMine is raised by retract post" do
      it "will respond with a 403" do
        expect(post_service_double).to receive(:retract_post).and_raise(Diaspora::NotMine)
        message = alice.post(:status_message, text: "hey", to: alice.aspects.first.id)
        delete :destroy, format: :js, id: message.id
        expect(response.body).to eq("You are not allowed to do that")
        expect(response.status).to eq(403)
      end
    end
  end
end
