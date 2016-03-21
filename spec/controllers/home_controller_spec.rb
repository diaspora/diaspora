#   Copyright (c) 2010-2012, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require "spec_helper"

describe HomeController, type: :controller do
  describe "#show" do
    it "does not redirect for :html" do
      get :show
      expect(response).not_to be_redirect
    end

    it "redirects for :mobile" do
      get :show, format: :mobile
      expect(response).to redirect_to(user_session_path)
    end

    context "redirection" do
      before do
        sign_in alice
      end

      it "points to the stream if a user has contacts" do
        get :show, home: true
        expect(response).to redirect_to(stream_path)
      end
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
