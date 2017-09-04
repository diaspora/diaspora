# frozen_string_literal: true

describe SocialRelayController, type: :controller do
  describe "#well_known" do
    it "responds to format json" do
      get :well_known, format: "json"
      expect(response.code).to eq("200")
    end

    it "contains json" do
      get :well_known, format: "json"
      json = JSON.parse(response.body)
      expect(json["scope"]).to be_present
    end
  end
end
