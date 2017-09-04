# frozen_string_literal: true

describe AvatarPresenter do
  describe "#base_hash" do
    it "calls image_url() for the avatars" do
      @profile = FactoryGirl.create(:profile_with_image_url, person: alice.person)
      @presenter = AvatarPresenter.new(@profile)
      expect(@profile).to receive(:image_url).exactly(3).times
      expect(@presenter.base_hash).to be_present
    end

    it "returns the default images if no images set" do
      @profile = FactoryGirl.create(:profile, person: alice.person)
      @presenter = AvatarPresenter.new(@profile)
      expect(@presenter.base_hash.keys).to eq(%i[small medium large])
      expect(@presenter.base_hash[:small]).to match(%r{/assets/user/default-[0-9a-f]{64}\.png})
      expect(@presenter.base_hash[:medium]).to match(%r{/assets/user/default-[0-9a-f]{64}\.png})
      expect(@presenter.base_hash[:large]).to match(%r{/assets/user/default-[0-9a-f]{64}\.png})
    end
  end
end
