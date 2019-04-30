# frozen_string_literal: true

describe TwoFactorAuthenticationsController, type: :controller do
  before do
    @user = FactoryGirl.create :user
    sign_in @user
  end

  describe "#show" do
    it "shows the deactivated state of 2fa" do
      get :show
      expect(response.body).to match I18n.t("two_factor_auth.title")
      expect(response.body).to match I18n.t("two_factor_auth.deactivated.status")
      expect(@user).to have_attributes(otp_required_for_login: nil)
    end

    it "shows the activated state of 2fa" do
      activate_2fa
      get :show
      expect(response.body).to match I18n.t("two_factor_auth.title")
      expect(response.body).to match I18n.t("two_factor_auth.activated.status")
      expect(response.body).to match I18n.t("two_factor_auth.recovery.button")
      expect(@user).to have_attributes(otp_required_for_login: true)
    end
  end

  describe "#create" do
    it "sets the otp_secret flag" do
      post :create, params: {user: {otp_required_for_login: "true"}}
      expect(response).to be_redirect
      expect(response.location).to match confirm_two_factor_authentication_path
    end
  end

  describe "#confirm_2fa" do
    context "2fa is not yet activated" do
      before do
        create_otp_token
      end
      it "shows the QR verification code" do
        get :confirm_2fa
        expect(response.body).to match I18n.t("two_factor_auth.confirm.title")
        expect(response.body).to include("svg")
        expect(response.body).to match(/#{@user.otp_secret.scan(/.{4}/).join(" ")}/)
        expect(response.body).to match I18n.t("two_factor_auth.input_token.label")
      end
    end
    context "2fa is already activated" do
      before do
        activate_2fa
      end

      it "redirects back" do
        get :confirm_2fa
        expect(response).to be_redirect
        expect(response.location).to match two_factor_authentication_path
      end
    end
  end

  describe "#confirm_and_activate_2fa" do
    before do
      create_otp_token
    end
    it "redirects back to confirm when token was wrong" do
      post :confirm_and_activate_2fa, params: {user: {code: "not valid token"}}
      expect(response.location).to match confirm_two_factor_authentication_path
      expect(flash[:alert]).to match I18n.t("two_factor_auth.flash.error_token")
    end
    it "redirects to #recovery_codes when token was correct" do
      post :confirm_and_activate_2fa, params: {user: {code: @user.current_otp}}
      expect(response.location).to match recovery_codes_two_factor_authentication_path
      expect(flash[:notice]).to match I18n.t("two_factor_auth.flash.success_activation")
    end
  end

  describe "#recovery_codes" do
    before do
      activate_2fa
    end
    it "shows recovery codes page" do
      get :recovery_codes
      expect(response.body).to match I18n.t("two_factor_auth.recovery.title")
      expect(@user).to have_attributes(otp_required_for_login: true)
    end
  end

  describe "#destroy" do
    before do
      activate_2fa
    end
    it "deactivates 2fa if password is correct" do
      delete :destroy, params: {two_factor_authentication: {password: @user.password}}
      expect(response).to be_redirect
      expect(flash[:notice]).to match I18n.t("two_factor_auth.flash.success_deactivation")
    end

    it "does nothing if password is wrong" do
      delete :destroy, params: {two_factor_authentication: {password: "a wrong password"}}
      expect(response).to be_redirect
      expect(flash[:alert]).to match I18n.t("users.destroy.wrong_password")
    end
  end

  def create_otp_token
    @user.otp_secret = User.generate_otp_secret(32)
    @user.save!
  end

  def confirm_activation
    @user.otp_required_for_login = true
    @user.save!
  end

  def activate_2fa
    create_otp_token
    confirm_activation
  end
end
