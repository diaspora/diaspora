# frozen_string_literal: true

require Rails.root.join("spec/shared_behaviors/stream")

describe Stream::Base do
  before do
    @stream = Stream::Base.new(alice)
  end

  describe "#stream_posts" do
    it "should returns the posts.for_a_stream" do
      posts = double
      allow(@stream).to receive(:posts).and_return(posts)
      allow(@stream).to receive(:like_posts_for_stream!)

      expect(posts).to receive(:for_a_stream).with(anything, anything, alice).and_return(posts)
      @stream.stream_posts
    end

    context "when alice has liked some posts" do
      before do
        bob.post(:status_message, text: "sup", to: bob.aspects.first.id)
        @liked_status = bob.posts.last
        @like = FactoryBot.create(:like, target: @liked_status, author: alice.person)
      end

      it "marks the posts as liked" do
        expect(@stream.stream_posts.first.user_like.id).to eq(@like.id)
      end
    end
  end

  describe "#people" do
    it "excludes blocked people" do
      expect(@stream).to receive(:stream_posts).and_return(double.as_null_object)
      @stream.people
    end
  end

  describe "shared behaviors" do
    it_should_behave_like "it is a stream"
  end
end
