# frozen_string_literal: true

describe AvatarPresenter do
  describe "#base_hash" do
    it "calls image_url() for the avatars" do
      profile = FactoryGirl.create(:profile_with_image_url, person: alice.person)
      presenter = AvatarPresenter.new(profile)
      expect(profile).to receive(:image_url).exactly(4).times.and_call_original
      expect(presenter.base_hash).to be_present
    end

    it "returns nothing if no images set" do
      profile = FactoryGirl.create(:profile, person: alice.person)
      presenter = AvatarPresenter.new(profile)
      expect(presenter.base_hash).to be_nil
    end

    it "returns all relevant sizes" do
      profile = FactoryGirl.create(:profile_with_image_url, person: alice.person)
      base_hash = AvatarPresenter.new(profile).base_hash

      expect(base_hash[:small]).to be_truthy
      expect(base_hash[:medium]).to be_truthy
      expect(base_hash[:large]).to be_truthy
      expect(base_hash[:raw]).to be_truthy
    end
  end
end
