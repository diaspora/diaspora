# frozen_string_literal: true

describe LikesPresenter do
  before do
    bob.person.profile = FactoryBot.create(:profile_with_image_url)
    @status = alice.post(
      :status_message,
      text:   "This is a status message from alice",
      public: true,
      to:     "all"
    )
    bobs_like_service = LikeService.new(bob)
    like = bobs_like_service.create_for_post(@status.guid)
    @presenter = LikesPresenter.new(like, bob)
  end

  describe "#as_api_json" do
    it "works" do
      expect(@presenter.as_api_json).to be_present
    end

    it "confirm API V1 compliance" do
      like = @presenter.as_api_json
      expect(like.has_key?(:guid)).to be_truthy
      author = like[:author]
      expect(author).not_to be_nil
      expect(author).to include(guid: bob.guid)
      expect(author).to include(diaspora_id: bob.diaspora_handle)
      expect(author).to include(name: bob.name)
      expect(author).to include(avatar: bob.profile.image_url(size: :thumb_medium))
    end
  end
end
