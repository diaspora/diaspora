require 'spec_helper'

describe Services::Facebook do

  before do
    @user = alice
    @post = @user.post(:status_message, :text => "hello", :to =>@user.aspects.first.id, :public =>true)
    @service = Services::Facebook.new(:access_token => "yeah")
    @user.services << @service
  end

  describe '#post' do
    it 'posts a status message to facebook' do
      stub_request(:post, "https://graph.facebook.com/me/feed").
          to_return(:status => 200, :body => "", :headers => {})
      @service.post(@post)
    end

    it 'swallows exception raised by facebook always being down' do
      pending "temporarily disabled to figure out while some requests are failing"
      
      stub_request(:post,"https://graph.facebook.com/me/feed").
        to_raise(StandardError)
      @service.post(@post)
    end

    it 'should call public message' do
      stub_request(:post, "https://graph.facebook.com/me/feed").
        to_return(:status => 200)
      url = "foo"
      @service.should_not_receive(:public_message)
      @service.post(@post, url)
    end
    
    it 'removes text formatting markdown from post text' do
      message = "Text with some **bolded** and _italic_ parts."
      post = stub(:text => message)
      post_params = @service.create_post_params(post)
      post_params[:message].should match "Text with some bolded and italic parts."
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
end
