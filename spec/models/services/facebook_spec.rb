# frozen_string_literal: true

describe Services::Facebook, :type => :model do
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

    it 'removes text formatting markdown from post text' do
      message = double(urls: [])
      expect(message).to receive(:plain_text_without_markdown).and_return("")
      post = double(message: message, photos: [])
      post_params = @service.create_post_params(post)
    end

    it 'adds URL of post to end if no link at end' do
      message = "Some text."
      post = double(message: double(plain_text_without_markdown: message, urls: []), photos: [])
      post_params = @service.create_post_params(post)
      expect(post_params[:message]).to include '(via http:'
    end

    it 'adds URL at the end with ending with valid HTTP url' do
      message = "Some text and a link http://someserver1/testlink1 http://someserver2/testlink2 "
      post = double(message: double(plain_text_without_markdown: message, urls: ["http://someserver1/testlink1", "http://someserver2/testlink2"]), photos: [])
      post_params = @service.create_post_params(post)
      expect(post_params[:message]).to include '(via http:'
    end

    it 'adds URL at the end with ending valid HTTPS url' do
      message = "Some text and a link https://someserver1/testlink1 https://someserver2/testlink2 "
      post = double(message: double(plain_text_without_markdown: message, urls: ["https://someserver1/testlink1", "https://someserver2/testlink2"]), photos: [])
      post_params = @service.create_post_params(post)
      expect(post_params[:message]).to include '(via http:'
    end

    it 'adds URL at the end with HTTP urls internal' do
      message = "Some text and a link https://someserver1/testlink1 then some text"
      post = double(message: double(plain_text_without_markdown: message, urls: ["https://someserver1/testlink1"]), photos: [])
      post_params = @service.create_post_params(post)
      expect(post_params[:message]).to include '(via http:'
    end

    it 'adds URL of the end with HTTP urls internal trick case, bad URL should add to end' do
      message = "Some text and a link https://someserver1/testlink1 then some text http://"
      post = double(message: double(plain_text_without_markdown: message, urls: ["https://someserver1/testlink1"]), photos: [])
      post_params = @service.create_post_params(post)
      expect(post_params[:message]).to include '(via http:'
    end

    it 'sets facebook id on post' do
      stub_request(:post, "https://graph.facebook.com/me/feed").
	to_return(:status => 200, :body => '{"id": "12345"}', :headers => {})
      @service.post(@post)
      expect(@post.facebook_id).to match "12345"
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
      expect(post_params[:message]).to include '(via http:'
    end

    it "should include post url in message with photos when no text message" do
      @status_message = alice.build_post(:status_message, :text => "")
      @status_message.photos << @photos

      @status_message.save!
      alice.add_to_streams(@status_message, alice.aspects)

      post_params = @service.create_post_params(@status_message)
      expect(post_params[:message]).to include '(via http:'
    end

  end

  describe "#profile_photo_url" do
    it 'returns a large profile photo url' do
      @service.uid = "abc123"
      @service.access_token = "token123"
      expect(@service.profile_photo_url).to eq(
      "https://graph.facebook.com/abc123/picture?type=large&access_token=token123"
      )
    end
  end

  describe "#post_opts" do
    it "returns the facebook_id of the post" do
      @post.facebook_id = "2345"
      expect(@service.post_opts(@post)).to eq(facebook_id: "2345")
    end

    it "returns nil when the post has no facebook_id" do
      expect(@service.post_opts(@post)).to be_nil
    end
  end

  describe "#delete_from_service" do
    it "removes a post from facebook" do
      facebook_id = "2345"
      url = "https://graph.facebook.com/#{facebook_id}/"
      stub_request(:delete, "#{url}?access_token=#{@service.access_token}").to_return(status: 200)
      expect(@service).to receive(:delete_from_facebook).with(url, access_token: @service.access_token)

      @service.delete_from_service(facebook_id: facebook_id)
    end
  end
end
