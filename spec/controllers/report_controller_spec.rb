# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe ReportController, type: :controller do
  before do
    sign_in alice
    @message = alice.post(:status_message, text: "hey", to: alice.aspects.first.id)
    @comment = alice.comment!(@message, "flying pigs, everywhere")
  end

  describe "#index" do
    context "admin not signed in" do
      it "is behind redirect_unless_admin" do
        get :index
        expect(response).to redirect_to stream_path
      end
    end

    context "admin signed in" do
      before do
        Role.add_admin(alice.person)
      end
      it "succeeds and renders index" do
        get :index
        expect(response).to render_template("index")
      end
    end

    context "moderator signed in" do
      before do
        Role.add_moderator(alice.person)
      end
      it "succeeds and renders index" do
        get :index
        expect(response).to render_template("index")
      end
    end
  end

  describe "#create" do
    let(:comment_hash) {
      {text:    "facebook, is that you?",
       item_id: "#{@post.id}"}
    }

    context "report offensive post" do
      it "succeeds" do
        put :create, params: {report: {item_id: @message.id, item_type: "Post", text: "offensive content"}}
        expect(response.status).to eq(200)
        expect(Report.exists?(item_id: @message.id, item_type: "Post")).to be true
      end
    end
    context "report offensive comment" do
      it "succeeds" do
        put :create, params: {report: {item_id: @comment.id, item_type: "Comment", text: "offensive content"}}
        expect(response.status).to eq(200)
        expect(Report.exists?(item_id: @comment.id, item_type: "Comment")).to be true
      end
    end
  end

  describe "#update" do
    context "mark post report as user" do
      it "is behind redirect_unless_admin_or_moderator" do
        put :update, params: {id: @message.id, type: "post"}
        expect(response).to redirect_to stream_path
        expect(Report.where(reviewed: false, item_id: @message.id, item_type: "Post")).to be_truthy
      end
    end
    context "mark comment report as user" do
      it "is behind redirect_unless_admin_or_moderator" do
        put :update, params: {id: @comment.id, type: "comment"}
        expect(response).to redirect_to stream_path
        expect(Report.where(reviewed: false, item_id: @comment.id, item_type: "Comment")).to be_truthy
      end
    end

    context "mark post report as admin" do
      before do
        Role.add_admin(alice.person)
      end
      it "succeeds" do
        put :update, params: {id: @message.id, type: "post"}
        expect(response.status).to eq(302)
        expect(Report.where(reviewed: true, item_id: @message.id, item_type: "Post")).to be_truthy
      end
    end
    context "mark comment report as admin" do
      before do
        Role.add_admin(alice.person)
      end
      it "succeeds" do
        put :update, params: {id: @comment.id, type: "comment"}
        expect(response.status).to eq(302)
        expect(Report.where(reviewed: true, item_id: @comment.id, item_type: "Comment")).to be_truthy
      end
    end

    context "mark post report as moderator" do
      before do
        Role.add_moderator(alice.person)
      end

      it "succeeds" do
        put :update, params: {id: @message.id, type: "post"}
        expect(response.status).to eq(302)
        expect(Report.where(reviewed: true, item_id: @message.id, item_type: "Post")).to be_truthy
      end
    end

    context "mark comment report as moderator" do
      before do
        Role.add_moderator(alice.person)
      end
      it "succeeds" do
        put :update, params: {id: @comment.id, type: "comment"}
        expect(response.status).to eq(302)
        expect(Report.where(reviewed: true, item_id: @comment.id, item_type: "Comment")).to be_truthy
      end
    end
  end

  describe "#destroy" do
    context "destroy post as user" do
      it "is behind redirect_unless_admin_or_moderator" do
        delete :destroy, params: {id: @message.id, type: "post"}
        expect(response).to redirect_to stream_path
        expect(Report.where(reviewed: false, item_id: @message.id, item_type: "Post")).to be_truthy
      end
    end
    context "destroy comment as user" do
      it "is behind redirect_unless_admin_or_moderator" do
        delete :destroy, params: {id: @comment.id, type: "comment"}
        expect(response).to redirect_to stream_path
        expect(Report.where(reviewed: false, item_id: @comment.id, item_type: "Comment")).to be_truthy
      end
    end

    context "destroy post as admin" do
      before do
        Role.add_admin(alice.person)
      end
      it "succeeds" do
        delete :destroy, params: {id: @message.id, type: "post"}
        expect(response.status).to eq(302)
        expect(Report.where(reviewed: true, item_id: @message.id, item_type: "Post")).to be_truthy
      end
    end
    context "destroy comment as admin" do
      before do
        Role.add_admin(alice.person)
      end
      it "succeeds" do
        delete :destroy, params: {id: @comment.id, type: "comment"}
        expect(response.status).to eq(302)
        expect(Report.where(reviewed: true, item_id: @comment.id, item_type: "Comment")).to be_truthy
      end
    end

    context "destroy post as moderator" do
      before do
        Role.add_moderator(alice.person)
      end
      it "succeeds" do
        delete :destroy, params: {id: @message.id, type: "post"}
        expect(response.status).to eq(302)
        expect(Report.where(reviewed: true, item_id: @message.id, item_type: "Post")).to be_truthy
      end
    end
    context "destroy comment as moderator" do
      before do
        Role.add_moderator(alice.person)
      end
      it "succeeds" do
        delete :destroy, params: {id: @comment.id, type: "comment"}
        expect(response.status).to eq(302)
        expect(Report.where(reviewed: true, item_id: @comment.id, item_type: "Comment")).to be_truthy
      end
    end
  end
end
