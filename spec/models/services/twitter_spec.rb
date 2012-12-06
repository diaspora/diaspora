require 'spec_helper'

describe Services::Twitter do

  before do
    @user = alice
    @post = @user.post(:status_message, :text => "hello", :to =>@user.aspects.first.id, :photos => [])
    @service = Services::Twitter.new(:access_token => "yeah", :access_secret => "foobar")
    @user.services << @service
  end

  describe '#post' do
    it 'posts a status message to twitter' do
      Twitter::Client.any_instance.should_receive(:update).with(instance_of(String))
      @service.post(@post)
    end

     it 'swallows exception raised by twitter always being down' do
      pending
      Twitter::Client.any_instance.should_receive(:update).and_raise(StandardError)
      @service.post(@post)
    end

    it 'should call public message' do
      Twitter::Client.any_instance.stub(:update)
      url = "foo"
      @service.should_receive(:public_message).with(@post, url)
      @service.post(@post, url)
    end
    
    it 'removes text formatting markdown from post text' do
      message = "Text with some **bolded** and _italic_ parts."
      post = stub(:text => message, :photos => [])
      @service.public_message(post, '').should match "Text with some bolded and italic parts."
    end
    
  end
  
  describe "message size limits" do
    before :each do
      @long_message_start = SecureRandom.hex(25)
      @long_message_end = SecureRandom.hex(25)
    end

    it "should not truncate a short message" do
      short_message = SecureRandom.hex(20)
      short_post = stub(:text => short_message, :photos => [])
      @service.public_message(short_post, '').should match short_message
    end

    it "should truncate a long message" do
      long_message = SecureRandom.hex(220)
      long_post = stub(:text => long_message, :id => 1, :photos => [])
      @service.public_message(long_post, '').should match long_message.first(100)

    end

    it "should not truncate a long message with an http url" do
      long_message = " http://joindiaspora.com/a-very-long-url-name-that-will-be-shortened.html " + @long_message_end
      long_post = stub(:text => long_message, :id => 1, :photos => [])
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
      long_post = stub(:text => long_message, :id => 1, :photos => [])
      answer = @service.public_message(long_post, '')

      answer.should match /\.\.\./
    end
    
    it "should not truncate a message of maximum length" do
        exact_size_message = SecureRandom.hex(70)
        exact_size_post = stub(:text => exact_size_message, :id => 1, :photos => [])
        answer = @service.public_message(exact_size_post, '')
        
        answer.should match exact_size_message
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
        answer = @service.public_message(@status_message, '')
        answer.should include 'http'
    end
    
  end
  
  describe "#profile_photo_url" do
    it 'returns the original profile photo url' do
      user_stub = stub
      user_stub.should_receive(:profile_image_url_https).with("original").and_return("http://a2.twimg.com/profile_images/uid/avatar.png")
      Twitter::Client.any_instance.should_receive(:user).with("joindiaspora").and_return(user_stub)

      @service.nickname = "joindiaspora"
      @service.profile_photo_url.should == "http://a2.twimg.com/profile_images/uid/avatar.png"
    end
  end
end
