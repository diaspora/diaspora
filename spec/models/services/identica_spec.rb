require 'spec_helper'

describe Services::Identica do

  before do
    @user = make_user
    @user.aspects.create(:name => "whatever")
    @post = @user.post(:status_message, :message => "hello", :to =>@user.aspects.first.id)
    @service = Services::Identica.new(:access_token => "yeah", :access_secret => "foobar", :endpoint => 'http://identi.ca/api')
    @user.services << @service
  end

  describe '#post' do
    it 'posts a status message to identica' do
      Twitter.should_receive(:update).with(@post.message)
      @service.post(@post)
    end

    it 'swallows exception raised by identica always being down' do
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

