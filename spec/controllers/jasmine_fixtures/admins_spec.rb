# frozen_string_literal: true

describe AdminsController, type: :controller do
  describe "#dashboard" do
    before do
      @user = FactoryGirl.create :user
      Role.add_admin(@user.person)
      sign_in @user, scope: :user
    end

    context "jasmine fixtures" do
      it "generates a jasmine fixture", fixture: true do
        get :dashboard
        save_fixture(html_for("body"), "admin_dashboard")
      end
    end
  end
end
