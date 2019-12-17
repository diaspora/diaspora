# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe Devise::PasswordsController, type: :controller do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "#create" do
    context "when there is no such user" do
      it "succeeds" do
        post :create, params: {user: {email: "foo@example.com"}}
        expect(response).to redirect_to(new_user_session_path)
      end

      it "doesn't send email" do
        expect(Workers::ResetPassword).not_to receive(:perform_async)
        post :create, params: {user: {email: "foo@example.com"}}
      end
    end
    context "when there is a user with that email" do
      it "redirects to the login page" do
        post :create, params: {user: {email: alice.email}}
        expect(response).to redirect_to(new_user_session_path)
      end
      it "sends email (enqueued to Sidekiq)" do
        expect(Workers::ResetPassword).to receive(:perform_async).with(alice.id)
        post :create, params: {user: {email: alice.email}}
      end
    end
  end
end
