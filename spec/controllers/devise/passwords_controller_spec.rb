#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Devise::PasswordsController do
  include Devise::TestHelpers

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  describe "#create" do
    context "when there is no such user" do
      it "succeeds" do
        post :create, "user" => {"email" => "foo@example.com"}
        response.should be_success
      end
      it "doesn't send email" do
        expect {
          post :create, "user" => {"email" => "foo@example.com"}
        }.to change(Devise.mailer.deliveries, :length).by(0)
      end
    end
    context "when there is a user with that email" do
      it "redirects to the login page" do
        post :create, "user" => {"email" => alice.email}
        response.should redirect_to(new_user_session_path)
      end
      it "sends email" do
        expect {
          post :create, "user" => {"email" => alice.email}
        }.to change(Devise.mailer.deliveries, :length).by(1)
      end
      it "sends email with a non-blank body" do
        post :create, "user" => {"email" => alice.email}
        email = Devise.mailer.deliveries.last
        email_body = email.body.to_s
        email_body = email.html_part.body.raw_source if email_body.blank? && email.html_part.present?
        email_body.should_not be_blank
      end  
    end
  end
end