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
                                "password_confirmation" => "password",
                                "person" => {
                                  "profile" => {
                                    "first_name" => "John",
                                    "last_name" => "Doe"}}}}
  end

  describe "#create" do
    context "with valid parameters" do
      it "creates a user" do
        lambda { get :create, @valid_params }.should change(User, :count).by(1)
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
  end
end
