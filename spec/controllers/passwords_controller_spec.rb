#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe PasswordsController, :type => :controller do
  include Devise::TestHelpers

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "#create" do
    context "when there is no such user" do
      it "succeeds" do
        post :create, "user" => {"email" => "foo@example.com"}
        expect(response).to be_success
      end

      it "doesn't send email" do
        expect(Workers::ResetPassword).not_to receive(:perform_async)
        post :create, "user" => {"email" => "foo@example.com"}
      end
    end
    context "when there is a user with that email" do
      it "redirects to the login page" do
        post :create, "user" => {"email" => alice.email}
        expect(response).to redirect_to(new_user_session_path)
      end
      it "sends email (enqueued to Sidekiq)" do
        expect(Workers::ResetPassword).to receive(:perform_async).with(alice.id)
        post :create, "user" => {"email" => alice.email}
      end
    end
  end
end
