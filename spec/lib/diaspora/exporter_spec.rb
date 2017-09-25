# frozen_string_literal: true

describe Diaspora::Exporter do
  describe "#execute" do
    it "calls exporters and forms JSON" do
      expect_any_instance_of(Export::UserSerializer).to receive(:as_json).and_return(user: "user_data")
      expect_any_instance_of(Export::OthersDataSerializer).to receive(:as_json).and_return(others_date: "others_data")

      json = Diaspora::Exporter.new(FactoryGirl.create(:user)).execute
      expect(json).to include_json(
        version:     "2.0",
        user:        "user_data",
        others_date: "others_data"
      )
    end
  end
end
