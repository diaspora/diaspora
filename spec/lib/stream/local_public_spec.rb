# frozen_string_literal: true

require Rails.root.join("spec/shared_behaviors/stream")

describe Stream::LocalPublic do
  before do
    @stream = Stream::LocalPublic.new(alice)
  end

  describe "shared behaviors" do
    it_should_behave_like "it is a stream"
  end

  describe "#posts" do
    it "calls Post#all_local_public" do
      expect(Post).to receive(:all_local_public)
      @stream.posts
    end
  end
end
