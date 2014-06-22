require 'spec_helper'

describe Services::Facebook do

  before do
    @user = alice
    @post = @user.post(:status_message, :text => "hello", :to =>@user.aspects.first.id, :public =>true, :photos => [])
    @service = Services::Facebook.new(:access_token => "yeah")
    @user.services << @service
  end

  describe '#post' do
    it 'posts a status message to facebook' do
      stub_request(:post, "https://graph.facebook.com/me/feed").
          to_return(:status => 200, :body => '{"id": "12345"}', :headers => {})
      @service.post(@post)
    end

    it 'swallows exception raised by facebook always being down' do
      pending "temporarily disabled to figure out while some requests are failing"

      stub_request(:post,"https://graph.facebook.com/me/feed").
        to_raise(StandardError)
      @service.post(@post)
    end

    it 'removes text formatting markdown from post text' do
      message = double
      message.should_receive(:plain_text_without_markdown).and_return("")
      post = double(message: message, photos: [])
      post_params = @service.create_post_params(post)
    end

    it 'does not add post link when no photos' do
      message = "Some text."
      post = double(message: double(plain_text_without_markdown: message), photos: [])
      post_params = @service.create_post_params(post)
      post_params[:message].should_not include "http"
    end

    it 'sets facebook id on post' do
      stub_request(:post, "https://graph.facebook.com/me/feed").
	to_return(:status => 200, :body => '{"id": "12345"}', :headers => {})
      @service.post(@post)
      @post.facebook_id.should match "12345"
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

    it "should include post url in message with photos" do
      post_params = @service.create_post_params(@status_message)
      post_params[:message].should include 'http'
    end

  end

  describe "#profile_photo_url" do
    it 'returns a large profile photo url' do
      @service.uid = "abc123"
      @service.access_token = "token123"
      @service.profile_photo_url.should ==
      "https://graph.facebook.com/abc123/picture?type=large&access_token=token123"
    end
  end

  describe '#delete_post' do
    it 'removes a post from facebook' do
      @post.facebook_id = "2345"
      url="https://graph.facebook.com/#{@post.facebook_id}/"
      stub_request(:delete, "#{url}?access_token=#{@service.access_token}").to_return(:status => 200)
      @service.should_receive(:delete_from_facebook).with(url, {access_token: @service.access_token})

      @service.delete_post(@post)
    end
  end
end
