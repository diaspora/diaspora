#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require File.join(File.dirname(__FILE__), "..", "spec_helper")

describe RegistrationsController do
  include Devise::TestHelpers

  render_views

  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
    @valid_params = {"user" => {"username" => "jdoe",
                                "email" => "jdoe@example.com",
                                "password" => "password",
                                "password_confirmation" => "password"}}
  end

  describe "#create" do
    context "with valid parameters" do
      it "creates a user" do
        lambda { get :create, @valid_params }.should change(User, :count).by(1)
      end
      it "assigns @user" do
        get :create, @valid_params
        assigns(:user).should_not be_nil
      end
      it "sets the flash" do
        get :create, @valid_params
        flash[:notice].should_not be_empty
      end
      it "redirects to the root path" do
        get :create, @valid_params
        response.should redirect_to root_path
      end
    end
    context "with invalid parameters" do
      before do
        @valid_params["user"]["password_confirmation"] = "baddword"
        @invalid_params = @valid_params
      end
      it "does not create a user" do
        lambda { get :create, @invalid_params }.should_not change(User, :count)
      end
      it "assigns @user" do
        get :create, @valid_params
        assigns(:user).should_not be_nil
      end
      it "sets the flash error" do
        get :create, @invalid_params
        flash[:error].should_not be_blank
      end
      it "goes back to the form" do
        get :create, @invalid_params
        response.should be_redirect
      end
    end
  end
end
