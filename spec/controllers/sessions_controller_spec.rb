#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require "spec_helper"

describe SessionsController, type: :controller do
  include Devise::TestHelpers

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
      post :create, {"user" => {"remember_me" => "0", "username" => @user.username, "password" => "evankorth"}}
      expect(response).to be_redirect
      expect(response.location).to match /^#{stream_url}\??$/
    end

    it "redirects to /stream for a mobile user" do
      request.headers["X_MOBILE_DEVICE"] = true
      post :create, {"user" => {"remember_me" => "0", "username" => @user.username, "password" => "evankorth"}}
      expect(response).to be_redirect
      expect(response.location).to match /^#{stream_url}\??$/
    end
  end

  describe "#destroy" do
    before do
      sign_in :user, @user
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
end
