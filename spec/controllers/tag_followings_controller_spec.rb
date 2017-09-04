# frozen_string_literal: true

describe TagFollowingsController, type: :controller do
  describe "#manage" do
    context "not signed in" do
      it "redirects html requests" do
        get :manage
        expect(response).to redirect_to new_user_session_path
      end

      it "redirects mobile requests" do
        get :manage, format: :mobile
        expect(response).to redirect_to new_user_session_path(format: :mobile)
      end
    end
    context "signed in" do
      before do
        sign_in alice, scope: :user
      end

      it "redirects html requests" do
        get :manage
        expect(response).to redirect_to followed_tags_stream_path
      end

      it "does not redirect mobile requests" do
        get :manage, format: :mobile
        expect(response).not_to be_redirect
      end
    end
  end
end
