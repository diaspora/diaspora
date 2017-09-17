# frozen_string_literal: true

describe UsersController, type: :controller do
  before do
    sign_in alice, scope: :user
  end

  describe "#getting_started" do
    before do
      alice.invited_by = bob
      alice.save!
    end

    it "generates a jasmine fixture with no query", fixture: true do
      get :getting_started
      save_fixture(html_for("body"), "getting_started")
    end
  end
end
