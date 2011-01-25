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

  describe '#finder' do
    before do
      @user2 = Factory(:user)
      @user2_fb_id = '820651'
      @user2_fb_name = 'Maxwell Salzberg'
      @user2.services << Factory.build(:service, :provider => 'facebook' , :uid => @user2_fb_id)
      @fb_list_hash =  <<JSON
      {
        "data": [
          {
            "name": "#{@user2_fb_name}",
            "id": "#{@user2_fb_id}"
          }
        ]
      }
JSON
      @web_mock = mock()
      @web_mock.stub!(:body).and_return(@fb_list_hash)
      RestClient.stub!(:get).and_return(@web_mock)
    end

    it 'requests a friend list' do
      RestClient.should_receive(:get).with("https://graph.facebook.com/me/friends", {:params => {:access_token => @service.access_token}}).and_return(@web_mock)
      @service.finder
    end

    context 'returns a hash' do
      it 'returns a hash' do
        @service.finder.class.should == Hash
      end
      it 'contains a name' do
        @service.finder.values.include?({:name => @user2_fb_name}).should be_true
      end
      it 'contains a photo url' do
        pending
      end
      it 'contains a FB id' do
        @service.finder.include?(@user2_fb_id).should be_true
      end
      it 'contains a diaspora person object' do
        pending
      end
    end

  end
end
