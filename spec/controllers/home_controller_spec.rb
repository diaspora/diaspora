# frozen_string_literal: true

#   Copyright (c) 2010-2012, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe HomeController, type: :controller do
  describe "#show" do
    it "does not redirect for :html if there are at least 2 users and an admin" do
      allow(User).to receive(:count).and_return(2)
      allow(Role).to receive_message_chain(:where, :any?).and_return(true)
      allow(Role).to receive_message_chain(:where, :exists?).and_return(true)
      get :show
      expect(response).not_to be_redirect
    end

    it "redirects to the podmin page for :html if there are less than 2 users" do
      allow(User).to receive(:count).and_return(1)
      allow(Role).to receive_message_chain(:where, :any?).and_return(true)
      get :show
      expect(response).to redirect_to(podmin_path)
    end

    it "redirects to the podmin page for :html if there is no admin" do
      allow(User).to receive(:count).and_return(2)
      allow(Role).to receive_message_chain(:where, :any?).and_return(false)
      get :show
      expect(response).to redirect_to(podmin_path)
    end

    it "redirects to the podmin page for :html if there are less than 2 users and no admin" do
      allow(User).to receive(:count).and_return(0)
      allow(Role).to receive_message_chain(:where, :any?).and_return(false)
      get :show
      expect(response).to redirect_to(podmin_path)
    end

    it "redirects to the sign in page for :mobile" do
      get :show, format: :mobile
      expect(response).to redirect_to(user_session_path)
    end

    it "redirects to the stream if the user is signed in" do
      sign_in alice
      get :show
      expect(response).to redirect_to(stream_path)
    end
  end

  describe "#podmin" do
    it "succeeds" do
      get :podmin
      expect(response).to be_success
    end

    it "succeeds on mobile" do
      get :podmin, format: :mobile
      expect(response).to be_success
    end
  end

  describe "#toggle_mobile" do
    it "changes :mobile to :html" do
      session[:mobile_view] = true
      get :toggle_mobile
      expect(session[:mobile_view]).to be false
    end

    it "changes :html to :mobile" do
      session[:mobile_view] = nil
      get :toggle_mobile
      expect(session[:mobile_view]).to be true
    end
  end

  describe "#force_mobile" do
    it "changes :html to :mobile" do
      session[:mobile_view] = nil
      get :force_mobile
      expect(session[:mobile_view]).to be true
    end

    it "keeps :mobile" do
      session[:mobile_view] = true
      get :force_mobile
      expect(session[:mobile_view]).to be true
    end
  end
end
