# frozen_string_literal: true

describe ApplicationController, type: :request do
  describe "csrf token validation" do
    context "without a current user" do
      before do
        @user = alice
        @user.password = "evankorth"
        @user.password_confirmation = "evankorth"
        @user.save
      end

      it "redirects to the new session page on validation fails" do
        expect_any_instance_of(SessionsController).to receive(:verified_request?).and_return(false)
        post "/users/sign_in", params: {user: {remember_me: 0, username: @user.username, password: "evankorth"}}
        expect(response).to redirect_to new_user_session_path
        expect(flash[:error]).to eq(I18n.t("error_messages.csrf_token_fail"))
      end

      it "doesn't redirect to the new session page if the validation succeeded" do
        expect_any_instance_of(SessionsController).to receive(:verified_request?).and_return(true)
        post "/users/sign_in", params: {user: {remember_me: 0, username: @user.username, password: "evankorth"}}
        expect(response).to redirect_to stream_path
        expect(flash[:error]).to be_blank
      end
    end

    context "with a current user" do
      before do
        sign_in alice
      end

      it "signs out users if a wrong token was given" do
        expect_any_instance_of(UsersController).to receive(:verified_request?).and_return(false)
        put edit_user_path, params: {user: {language: "en"}}
        expect(response).to redirect_to new_user_session_path
        expect(flash[:error]).to eq(I18n.t("error_messages.csrf_token_fail"))
      end

      it "sends an email to the current user if the token validation failed" do
        expect_any_instance_of(UsersController).to receive(:verified_request?).and_return(false)
        expect(Workers::Mail::CsrfTokenFail).to receive(:perform_async).with(alice.id)
        put edit_user_path, params: {user: {language: "en"}}
      end

      it "doesn't sign out users if the token was correct" do
        expect_any_instance_of(UsersController).to receive(:verified_request?).and_return(true)
        put edit_user_path, params: {user: {language: "en"}}
        expect(response).not_to be_redirect
        expect(flash[:error]).to be_blank
      end
    end
  end
end
