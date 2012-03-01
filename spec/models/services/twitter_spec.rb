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
      Twitter.should_receive(:update).with(@post.text)
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
  describe "message size limits" do
    before :each do
      @long_message_start = ActiveSupport::SecureRandom.hex(25)
      @long_message_end = ActiveSupport::SecureRandom.hex(25)
    end

    it "should not truncate a short message" do
      short_message = ActiveSupport::SecureRandom.hex(20)
      short_post = stub(:text => short_message )
      @service.public_message(short_post, '').should == short_message
    end
    it "should truncate a long message" do
      long_message = ActiveSupport::SecureRandom.hex(220)
      long_post = stub(:text => long_message )
      @service.public_message(long_post, '').should == long_message.first(137) + "..."
    end
    it "should not truncate a long message with an http url" do
      long_message = @long_message_start + " http://joindiaspora.com/a-very-long-url-name-that-will-be-shortened.html " + @long_message_end
      long_post = stub(:text => long_message )
      answer = @service.public_message(long_post, '')

      answer.starts_with?( @long_message_start ).should be_true
      answer.ends_with?( @long_message_end ).should be_true
    end
    it "should not truncate a long message with an https url" do
      long_message = @long_message_start + " https://joindiaspora.com/a-very-long-url-name-that-will-be-shortened.html " + @long_message_end
      long_post = stub(:text => long_message )

      answer = @service.public_message(long_post, '')
      answer.starts_with?( @long_message_start ).should be_true
      answer.ends_with?( @long_message_end ).should be_true
    end
    it "should truncate a long message with an ftp url" do
      long_message = @long_message_start + " ftp://joindiaspora.com/a-very-long-url-name-that-will-be-shortened.html " + @long_message_end
      long_post = stub(:text => long_message )
      answer = @service.public_message(long_post, '')

      answer.starts_with?( @long_message_start ).should be_true
      answer.ends_with?( @long_message_end ).should_not be_true
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
