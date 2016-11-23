require "spec_helper"

describe ProfilePresenter do
  let(:profile) { FactoryGirl.create(:profile_with_image_url, person: alice.person) }
  let(:presenter) { ProfilePresenter.new(profile) }

  before do
    alice.profile.destroy
  end

  describe "#for_hovercard" do
    subject { presenter.for_hovercard }

    it "contains tags and avatar" do
      expect(subject[:avatar]).to eq(profile.image_url_medium)
      expect(subject[:tags]).to match_array(%w(one two))
    end
  end
end
