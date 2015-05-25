require "spec_helper"

describe EventPresenter do
  before do
    status_message = StatusMessage.new
    event = status_message.build_event(name: "name", date: "201501010000", location: "location")
    @presenter = EventPresenter.new(event)
  end

  describe "#base_hash" do
    it "should be successfully generated" do
      expect(@presenter.base_hash).to be_present
    end
  end
end
