# frozen_string_literal: true

describe TwoFactorAuthenticationsController, type: :request do
  context "user with two-factor authentication deactivated" do
    before do
      sign_in user
    end

    context "can activate two-factor authentication" do
      let!(:user) { FactoryGirl.create(:user) }

      it "allows to activate two-factor authentication" do
        get "/two_factor_authentication"
        expect(response).to render_template(:show)
        expect(response.body).to match("Two-factor authentication not activated")
        post "/two_factor_authentication",
             params: {otp_required_for_login: true}
        expect(response).to be_redirect
        follow_redirect!
        expect(response).to render_template(:confirm_2fa)
      end

      context "with first confirm done" do
        before do
          generate_user_otp_secret
        end

        it "generates a QR code and let the user confirm the activation" do
          post "/two_factor_authentication/confirm",
               params: {user: {code: user.current_otp}}
          expect(response).to be_redirect
          follow_redirect!
          expect(response).to render_template(:recovery_codes)
          get "/two_factor_authentication"
          expect(response).to render_template(:show)
          expect(response.body).to match("Two-factor authentication activated")
        end
      end
    end
  end

  context "for a user with two-factor authentication activated" do
    before do
      activate_2fa
    end

    context "when logging in with TOTP token" do
      let!(:user) { FactoryGirl.create(:user) }

      it "redirects to two-factor page" do
        post "/users/sign_in",
             params: {user: {username: user.username, password: user.password}}
        expect(response).to render_template(:two_factor)
        post "/users/sign_in",
             params: {user: {username: user.username,
                             password: user.password,
                             otp_attempt: user.current_otp}}
        expect(response.body).to match "stream"
      end
    end

    pending "when logging in with recovery code"

    pending "can deactivate two-factor auth"
  end

  def generate_user_otp_secret
    user.otp_secret = User.generate_otp_secret(32)
    user.save!
  end

  def activate_2fa
    generate_user_otp_secret
    user.otp_required_for_login = true
    user.save!
  end
end
