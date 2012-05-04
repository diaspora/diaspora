require 'spec_helper'

describe Services::Twitter do

  before do
    @user = alice
    @post = @user.post(:status_message, :text => "hello", :to =>@user.aspects.first.id)
    @service = Services::Twitter.new(:access_token => "yeah", :access_secret => "foobar")
    @user.services << @service
  end

  describe '#post' do
    it 'posts a status message to twitter' do
      Twitter.should_receive(:update).with(instance_of(String))
      @service.post(@post)
    end

     it 'swallows exception raised by twitter always being down' do
      pending
      Twitter.should_receive(:update).and_raise(StandardError)
      @service.post(@post)
    end

    it 'should call public message' do
      Twitter.stub!(:update)
      url = "foo"
      @service.should_receive(:public_message).with(@post, url)
      @service.post(@post, url)
    end
  end
  describe "message size limits" do
    before :each do
      @long_message_start = SecureRandom.hex(25)
      @long_message_end = SecureRandom.hex(25)
    end

    it "should not truncate a short message" do
      short_message = SecureRandom.hex(20)
      short_post = stub(:text => short_message )
      @service.public_message(short_post, '').should include(short_message)
    end

    it "should truncate a long message" do
      long_message = SecureRandom.hex(220)
      long_post = stub(:text => long_message, :id => 1 )
      @service.public_message(long_post, '').should match long_message.first(100)

    end

    it "should not truncate a long message with an http url" do
      long_message = " http://joindiaspora.com/a-very-long-url-name-that-will-be-shortened.html " + @long_message_end
      long_post = stub(:text => long_message, :id => 1 )
      @post.text = long_message
      answer = @service.public_message(@post, '')

      answer.should_not match /\.\.\./
    end

    it "should not truncate a long message with an https url" do
      long_message = " https://joindiaspora.com/a-very-long-url-name-that-will-be-shortened.html " + @long_message_end
      @post.text = long_message
      answer = @service.public_message(@post, '')
      answer.should_not match /\.\.\./
    end

    it "should truncate a long message with an ftp url" do
      long_message = @long_message_start + " ftp://joindiaspora.com/a-very-long-url-name-that-will-be-shortened.html " + @long_message_end
      long_post = stub(:text => long_message, :id => 1 )
      answer = @service.public_message(long_post, '')

      answer.should match /\.\.\./
    end

  end
  describe "#profile_photo_url" do
    it 'returns the original profile photo url' do
      stub_request(:get, "https://api.twitter.com/1/users/profile_image/joindiaspora?size=original").
        to_return(:status => 302, :body => "", :headers => {:location => "http://a2.twimg.com/profile_images/uid/avatar.png"})

      @service.nickname = "joindiaspora"
      @service.profile_photo_url.should == 
      "http://a2.twimg.com/profile_images/uid/avatar.png"
    end
  end
end
