# frozen_string_literal: true

describe InvitationCodesController, type: :controller do
  describe "#show" do
    it "redirects to the root page if the invitation code is invalid" do
      get :show, params: {id: "InvalidInvitationCode"}
      expect(response).to redirect_to root_path
      expect(flash[:notice]).to eq(I18n.t("invitation_codes.not_valid"))
    end

    context "valid invitation code" do
      let(:invitation_token) { alice.invitation_code.token }

      it "redirects logged out users to the sign in page" do
        post :show, params: {id: invitation_token}
        expect(response).to redirect_to new_user_registration_path(invite: {token: invitation_token})
      end

      it "redirects logged in users the the inviters page" do
        sign_in bob
        post :show, params: {id: invitation_token}
        expect(response).to redirect_to person_path(alice.person)
        expect(flash[:notice]).to eq(I18n.t("invitation_codes.already_logged_in", inviter: alice.name))
      end
    end
  end
end
