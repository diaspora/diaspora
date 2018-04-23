# frozen_string_literal: true

describe Services::Twitter, :type => :model do
  before do
    @user = alice
    @post = @user.post(:status_message, :text => "hello", :to =>@user.aspects.first.id, :photos => [])
    @service = Services::Twitter.new(:access_token => "yeah", :access_secret => "foobar")
    @user.services << @service
  end

  describe '#post' do

    before do
      allow_any_instance_of(Twitter::REST::Client).to receive(:update) { Twitter::Tweet.new(id: "1234") }
    end

    it 'posts a status message to twitter' do
      expect_any_instance_of(Twitter::REST::Client).to receive(:update).with(instance_of(String))
      @service.post(@post)
    end

    it 'sets the tweet_id on the post' do
      @service.post(@post)
      expect(@post.tweet_id).to match "1234"
    end

    it 'should call build_twitter_post' do
      url = "foo"
      expect(@service).to receive(:build_twitter_post).with(@post, 0)
      @service.post(@post, url)
    end

    it 'removes text formatting markdown from post text' do
      message = double
      expect(message).to receive(:plain_text_without_markdown).and_return("")
      post = double(message: message, photos: [])
      @service.send(:build_twitter_post, post)
    end

  end

  describe "message size limits" do
    before :each do
      @long_message_start = SecureRandom.hex(165)
      @long_message_end = SecureRandom.hex(165)
    end

    it "should not truncate a short message" do
      short_message = SecureRandom.hex(20)
      short_post = double(message: double(plain_text_without_markdown: short_message), photos: [])
      expect(@service.send(:build_twitter_post, short_post)).to match short_message
    end

    it "should truncate a long message" do
      long_message = SecureRandom.hex(360)
      long_post = double(message: double(plain_text_without_markdown: long_message), id: 1, photos: [])
      answer = @service.send(:build_twitter_post, long_post)
      expect(answer.length).to be < long_message.length
      expect(answer).to include "http:"
    end

    it "should not truncate a long message with an http url" do
      long_message = " http://joindiaspora.com/a-very-long-url-name-that-will-be-shortened.html " + @long_message_end
      long_post = double(message: double(plain_text_without_markdown: long_message), id: 1, photos: [])
      @post.text = long_message
      answer = @service.send(:build_twitter_post, @post)

      expect(answer).not_to match /\.\.\./
    end

    it "should not cut links when truncating a post" do
      long_message = SecureRandom.hex(40) +
         " http://joindiaspora.com/a-very-long-url-name-that-will-be-shortened.html " +
         SecureRandom.hex(195)
      long_post = double(message: double(plain_text_without_markdown: long_message), id: 1, photos: [])
      answer = @service.send(:build_twitter_post, long_post)

      expect(answer).to match /\.\.\./
      expect(answer).to match /shortened\.html/
    end

    it "should append the otherwise-cut link when truncating a post" do
      long_message = "http://joindiaspora.com/a-very-long-decoy-url.html " + SecureRandom.hex(20) +
         " http://joindiaspora.com/a-very-long-url-name-that-will-be-shortened.html " + SecureRandom.hex(195) +
         " http://joindiaspora.com/a-very-long-decoy-url-part-2.html"
      long_post = double(message: double(plain_text_without_markdown: long_message), id: 1, photos: [])
      answer = @service.send(:build_twitter_post, long_post)

      expect(answer).to match /\.\.\./
      expect(answer).to match /shortened\.html/
    end

    it "should not truncate a long message with an https url" do
      long_message = " https://joindiaspora.com/a-very-long-url-name-that-will-be-shortened.html " + @long_message_end
      @post.text = long_message
      answer = @service.send(:build_twitter_post, @post)
      expect(answer).not_to match /\.\.\./
    end

    it "should truncate a long message with an ftp url" do
      long_message = @long_message_start + " ftp://joindiaspora.com/a-very-long-url-name-that-will-be-shortened.html " + @long_message_end
      long_post = double(message: double(plain_text_without_markdown: long_message), id: 1, photos: [])
      answer = @service.send(:build_twitter_post, long_post)

      expect(answer).to match /\.\.\./
    end

    it "should not truncate a message of maximum length" do
      exact_size_message = SecureRandom.hex(140)
      exact_size_post = double(message: double(plain_text_without_markdown: exact_size_message), id: 1, photos: [])
      answer = @service.send(:build_twitter_post, exact_size_post)

      expect(answer).to match exact_size_message
    end

  end

  describe "with photo" do
    before do
      @photos = [alice.build_post(:photo, :pending => true, :user_file=> File.open(photo_fixture_name)),
                 alice.build_post(:photo, :pending => true, :user_file=> File.open(photo_fixture_name))]

      @photos.each(&:save!)

      @status_message = alice.build_post(:status_message, :text => "the best pebble.")
        @status_message.photos << @photos

      @status_message.save!
      alice.add_to_streams(@status_message, alice.aspects)
    end

    it "should include post url in short message with photos" do
        answer = @service.send(:build_twitter_post, @status_message)
        expect(answer).to include 'http'
    end

  end

  describe "#profile_photo_url" do
    it 'returns the original profile photo url' do
      user_double = double
      expect(user_double).to receive(:profile_image_url_https).with("original").and_return("http://a2.twimg.com/profile_images/uid/avatar.png")
      expect_any_instance_of(Twitter::REST::Client).to receive(:user).with("joindiaspora").and_return(user_double)

      @service.nickname = "joindiaspora"
      expect(@service.profile_photo_url).to eq("http://a2.twimg.com/profile_images/uid/avatar.png")
    end
  end

  describe "#post_opts" do
    it "returns the tweet_id of the post" do
      @post.tweet_id = "2345"
      expect(@service.post_opts(@post)).to eq(tweet_id: "2345")
    end

    it "returns nil when the post has no tweet_id" do
      expect(@service.post_opts(@post)).to be_nil
    end
  end
end
