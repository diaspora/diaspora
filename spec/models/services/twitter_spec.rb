require 'spec_helper'

describe Services::Twitter do

  before do
    @user = alice
    @post = @user.post(:status_message, :message => "hello", :to =>@user.aspects.first.id)
    @service = Services::Twitter.new(:access_token => "yeah", :access_secret => "foobar")
    @user.services << @service
  end

  describe '#post' do
    it 'posts a status message to twitter' do
      Twitter.should_receive(:update).with(@post.message)
      @service.post(@post)
    end

     it 'swallows exception raised by twitter always being down' do
      Twitter.should_receive(:update).and_raise
      @service.post(@post)
    end

    it 'should call public message' do
      Twitter.stub!(:update)
      url = "foo"
      @service.should_receive(:public_message).with(@post, url)
      @service.post(@post, url)
    end
  end
end
