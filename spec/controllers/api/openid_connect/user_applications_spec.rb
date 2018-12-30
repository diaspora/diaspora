# frozen_string_literal: true

describe Api::OpenidConnect::UserApplicationsController, type: :controller do
  before do
    @app = FactoryGirl.create(:o_auth_application_with_xss)
    @user = FactoryGirl.create :user
    FactoryGirl.create :auth_with_default_scopes, user: @user, o_auth_application: @app
    sign_in @user, scope: :user
  end

  context "when try to XSS" do
    it "should not include XSS script" do
      get :index
      expect(response.body).to_not include("<script>alert(0);</script>")
    end
  end
end
