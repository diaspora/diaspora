require 'spec_helper'

describe Services::Facebook do

  before do
    @user = alice
    @post = @user.post(:status_message, :message => "hello", :to =>@user.aspects.first.id)
    @service = Services::Facebook.new(:access_token => "yeah")
    @user.services << @service
  end

  describe '#post' do
    it 'posts a status message to facebook' do
      RestClient.should_receive(:post).with("https://graph.facebook.com/me/feed", :message => @post.message, :access_token => @service.access_token)
      @service.post(@post)
    end
    it 'swallows exception raised by facebook always being down' do
      RestClient.should_receive(:post).and_raise
      @service.post(@post)
    end

    it 'should call public message' do
      RestClient.stub!(:post)
      url = "foo"
      @service.should_receive(:public_message).with(@post, url)
      @service.post(@post, url)
    end
  end
end
