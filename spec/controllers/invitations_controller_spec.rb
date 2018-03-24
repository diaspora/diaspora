# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe InvitationsController, type: :controller do
  describe "#create" do
    let(:referer) { "http://test.host/cats/foo" }
    let(:invite_params) { {email_inviter: {emails: "abc@example.com"}} }

    before do
      sign_in alice, scope: :user
      request.env["HTTP_REFERER"] = referer
    end

    context "no emails" do
      let(:invite_params) { {email_inviter: {emails: ""}} }

      it "does not create an EmailInviter" do
        expect(Workers::Mail::InviteEmail).not_to receive(:perform_async)
        post :create, params: invite_params
      end

      it "returns to the previous page" do
        post :create, params: invite_params
        expect(response).to redirect_to referer
      end

      it "flashes an error" do
        post :create, params: invite_params
        expect(flash[:error]).to eq(I18n.t("invitations.create.empty"))
      end
    end

    context "only valid emails" do
      let(:emails) { "mbs@gmail.com" }
      let(:invite_params) { {email_inviter: {emails: emails}} }

      it "creates an InviteEmail worker" do
        expect(Workers::Mail::InviteEmail).to receive(:perform_async).with(
          emails, alice.id, invite_params[:email_inviter]
        )
        post :create, params: invite_params
      end

      it "returns to the previous page on success" do
        post :create, params: invite_params
        expect(response).to redirect_to referer
      end

      it "flashes a notice" do
        post :create, params: invite_params
        expected = I18n.t("invitations.create.sent", emails: emails)
        expect(flash[:notice]).to eq(expected)
      end
    end

    context "only invalid emails" do
      let(:emails) { "invalid_email" }
      let(:invite_params) { {email_inviter: {emails: emails}} }

      it "does not create an InviteEmail worker" do
        expect(Workers::Mail::InviteEmail).not_to receive(:perform_async)
        post :create, params: invite_params
      end

      it "returns to the previous page" do
        post :create, params: invite_params
        expect(response).to redirect_to referer
      end

      it "flashes an error" do
        post :create, params: invite_params

        expected = I18n.t("invitations.create.rejected", emails: emails)
        expect(flash[:error]).to eq(expected)
      end
    end

    context "mixed valid and invalid emails" do
      let(:valid_emails) { "foo@bar.com,mbs@gmail.com" }
      let(:invalid_emails) { "invalid_email" }
      let(:invite_params) { {email_inviter: {emails: valid_emails + "," + invalid_emails}} }

      it "creates an InviteEmail worker" do
        expect(Workers::Mail::InviteEmail).to receive(:perform_async).with(
          valid_emails, alice.id, invite_params[:email_inviter]
        )
        post :create, params: invite_params
      end

      it "returns to the previous page" do
        post :create, params: invite_params
        expect(response).to redirect_to referer
      end

      it "flashes a notice" do
        post :create, params: invite_params
        expected = I18n.t("invitations.create.sent", emails: valid_emails.split(",").join(", ")) + ". " +
          I18n.t("invitations.create.rejected", emails: invalid_emails)
        expect(flash[:error]).to eq(expected)
      end
    end

    context "with registration disabled" do
      before do
        AppConfig.settings.enable_registrations = false
      end

      it "displays an error if invitations are closed" do
        AppConfig.settings.invitations.open = false

        post :create, params: invite_params

        expect(flash[:error]).to eq(I18n.t("invitations.create.closed"))
      end

      it "displays an error when no invitations are left" do
        alice.invitation_code.update_attributes(count: 0)

        post :create, params: invite_params

        expect(flash[:error]).to eq(I18n.t("invitations.create.no_more"))
      end
    end

    it "does not display an error when registration is open" do
      AppConfig.settings.invitations.open = false
      alice.invitation_code.update_attributes(count: 0)

      post :create, params: invite_params

      expect(flash[:error]).to be_nil
    end
  end

  describe '#new' do
    it 'renders' do
      sign_in alice, scope: :user
      get :new
    end
  end

  describe 'redirect logged out users to the sign in page' do
    it 'redriects #new' do
      get :new
      expect(response).to be_redirect
      expect(response).to redirect_to new_user_session_path
    end

    it 'redirects #create' do
      post :create
      expect(response).to be_redirect
      expect(response).to redirect_to new_user_session_path
    end
  end

  describe '.valid_email?' do
    it 'returns false for empty email' do
      expect(subject.send(:valid_email?, '')).to be false
    end

    it 'returns false for email without @-sign' do
      expect(subject.send(:valid_email?, 'foo')).to be false
    end

    it 'returns true for valid email' do
      expect(subject.send(:valid_email?, 'foo@bar.com')).to be true
    end
  end

  describe '.html_safe_string_from_session_array' do
    it 'returns "" for blank session[key]' do
      expect(subject.send(:html_safe_string_from_session_array, :blank)).to eq ""
    end

    it 'returns "" if session[key] is not an array' do
      session[:test_key] = "test"
      expect(subject.send(:html_safe_string_from_session_array, :test_key)).to eq ""
    end

    it 'returns the correct value' do
      session[:test_key] = ["test", "foo"]
      expect(subject.send(:html_safe_string_from_session_array, :test_key)).to eq "test, foo"
    end

    it 'sets session[key] to nil' do
      session[:test_key] = ["test"]
      subject.send(:html_safe_string_from_session_array, :test_key)
      expect(session[:test_key]).to be nil
    end
  end
end
