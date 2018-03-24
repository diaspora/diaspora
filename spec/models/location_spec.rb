# frozen_string_literal: true

describe Location, type: :model do
  describe "before validation" do
    let(:status) { FactoryGirl.create(:status_message) }

    it "should create new location when it has coordinates" do
      location = Location.new(coordinates: "1,2", status_message: status)
      expect(location.save).to be true
    end

    it "should not create new location when it does not have coordinates" do
      location = Location.new(status_message: status)
      expect(location.save).to be false
    end
  end
end
