# frozen_string_literal: true

describe ProfilePresenter do
  let(:profile) { FactoryGirl.create(:profile_with_image_url, person: alice.person) }

  describe "#for_hovercard" do
    it "contains tags and avatar" do
      hash = ProfilePresenter.new(profile).for_hovercard
      expect(hash[:avatar]).to eq(profile.image_url_medium)
      expect(hash[:tags]).to match_array(%w(one two))
    end
  end
end
