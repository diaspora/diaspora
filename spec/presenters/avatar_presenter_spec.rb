# frozen_string_literal: true

describe AvatarPresenter do
  describe "#base_hash" do
    it "calls image_url() for the avatars" do
      profile = FactoryGirl.create(:profile_with_image_url, person: alice.person)
      presenter = AvatarPresenter.new(profile)
      expect(profile).to receive(:image_url).exactly(3).times.and_call_original
      expect(presenter.base_hash).to be_present
    end

    it "returns nothing if no images set" do
      profile = FactoryGirl.create(:profile, person: alice.person)
      presenter = AvatarPresenter.new(profile)
      expect(presenter.base_hash).to be_nil
    end
  end
end
