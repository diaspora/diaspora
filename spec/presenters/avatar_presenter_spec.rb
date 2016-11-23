require "spec_helper"

describe AvatarPresenter do
  let(:presenter) { AvatarPresenter.new(profile) }

  describe "#base_hash" do
    subject { presenter.base_hash }

    context "a profile with an avatar" do
      let(:profile) { FactoryGirl.build(:profile_with_image_url, person: alice.person) }

      it "calls image_url() for the avatars" do
        expect(profile).to receive(:image_url).exactly(3).times
        expect(subject).to be_present
      end
    end

    context "a default profile" do
      let(:profile) { FactoryGirl.build(:profile, person: alice.person) }

      it "returns the default images" do
        expect(subject).to eq(
          small:  "/assets/user/default.png",
          medium: "/assets/user/default.png",
          large:  "/assets/user/default.png"
        )
      end
    end
  end
end
