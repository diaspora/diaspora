require "spec_helper"

describe ContactPresenter do
  before do
    @presenter = ContactPresenter.new(alice.contact_for(bob.person), alice)
  end

  describe "#base_hash" do
    it "works" do
      expect(@presenter.base_hash).to be_present
    end
  end

  describe "#full_hash" do
    it "works" do
      expect(@presenter.full_hash).to be_present
    end
  end

  describe "#full_hash_with_person" do
    it "works" do
      expect(@presenter.full_hash_with_person).to be_present
    end

    it "has relationship information" do
      expect(@presenter.full_hash_with_person[:person][:relationship]).to be(:mutual)
    end
  end
end
