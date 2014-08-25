#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper' 

describe SessionsController, :type => :controller do
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
      @request.env['HTTP_USER_AGENT'] = 'Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_1 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8B117 Safari/6531.22.7'
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
      @request.env['HTTP_USER_AGENT'] = 'Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_1 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8B117 Safari/6531.22.7'
      delete :destroy
      expect(response).to redirect_to root_path
    end
  end
end
