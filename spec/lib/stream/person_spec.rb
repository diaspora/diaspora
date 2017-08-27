# frozen_string_literal: true

require Rails.root.join('spec', 'shared_behaviors', 'stream')

describe Stream::Person do
  describe "shared behaviors" do
    before do
      @stream = Stream::Person.new(alice, bob.person, max_time: Time.zone.now, order: "updated_at")
    end

    it_should_behave_like "it is a stream"
  end

  describe "#posts" do
    it "calls user#posts_from if the user is present" do
      stream = Stream::Person.new(alice, bob.person, max_time: Time.zone.now, order: "updated_at")
      expect(alice).to receive(:posts_from).with(bob.person)
      stream.posts
    end
  end

  it "returns the most recent posts" do
    posts = []
    fetched_posts = []

    aspect = bob.aspects.first.id
    Timecop.scale(600) do
      16.times do |n|
        posts << bob.post(:status_message, text: "hello#{n}", to: aspect)
        posts << bob.post(:status_message, text: "hello#{n}", public: true)
      end

      fetched_posts = Stream::Person.new(alice, bob.person).stream_posts
    end

    posts = posts.reverse.slice(0..14)
    fetched_posts = fetched_posts.first(15)

    expect(fetched_posts).to eq(posts)
  end
end
