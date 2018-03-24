# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe SessionsController, type: :controller do
  let(:mock_access_token) { Object.new }

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = alice
    @user.password = "evankorth"
    @user.password_confirmation = "evankorth"
    @user.save
  end

  describe "#create" do
    it "redirects to /stream for a non-mobile user" do
      post :create, params: {user: {remember_me: "0", username: @user.username, password: "evankorth"}}
      expect(response).to be_redirect
      expect(response.location).to match /^#{stream_url}\??$/
    end

    it "redirects to /stream for a mobile user" do
      request.headers["X_MOBILE_DEVICE"] = true
      post :create, params: {user: {remember_me: "0", username: @user.username, password: "evankorth"}}
      expect(response).to be_redirect
      expect(response.location).to match /^#{stream_url}\??$/
    end
  end

  describe "#destroy" do
    before do
      sign_in @user, scope: :user
    end
    it "redirects to / for a non-mobile user" do
      delete :destroy
      expect(response).to redirect_to new_user_session_path
    end

    it "redirects to / for a mobile user" do
      request.headers["X_MOBILE_DEVICE"] = true
      delete :destroy
      expect(response).to redirect_to root_path
    end
  end

  describe "#reset_authentication_token" do
    context "for a logged in user" do
      before do
        sign_in @user, scope: :user
      end

      it "succeeds" do
        expect { @controller.send(:reset_authentication_token) }.to_not raise_error
      end
    end

    context "for a logged out user" do
      before do
        sign_out :user
      end

      it "succeeds" do
        expect { @controller.send(:reset_authentication_token) }.to_not raise_error
      end
    end
  end
end
