require 'spec_helper'

describe Services::Facebook do

  before do
    @user = alice
    @post = @user.post(:status_message, :text => "hello", :to =>@user.aspects.first.id)
    @service = Services::Facebook.new(:access_token => "yeah")
    @user.services << @service
  end

  describe '#post' do
    it 'posts a status message to facebook' do
      RestClient.should_receive(:post).with("https://graph.facebook.com/me/feed", :message => @post.text, :access_token => @service.access_token)
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

  context 'finder' do
    before do 
      @user2 = Factory.create(:user_with_aspect)
      @user2_fb_id = '820651'
      @user2_fb_name = 'Maxwell Salzberg'
      @user2_fb_photo_url = "http://cdn.fn.com/pic1.jpg"
      @user2_service = Services::Facebook.new(:uid => @user2_fb_id, :access_token => "yo")
      @user2.services << @user2_service
      @fb_list_hash =  <<JSON
      {
        "data": [
          {
            "name": "#{@user2_fb_name}",
            "id": "#{@user2_fb_id}",
            "picture": "#{@user2_fb_photo_url}"
          },
          {
            "name": "Person to Invite",
            "id": "abc123",
            "picture": "http://cdn.fn.com/pic1.jpg"
          }
        ]
      }
JSON
      @web_mock = mock()
      @web_mock.stub!(:body).and_return(@fb_list_hash)
      RestClient.stub!(:get).and_return(@web_mock)
    end

    describe '#save_friends' do
      it 'requests a friend list' do
        RestClient.should_receive(:get).with("https://graph.facebook.com/me/friends", {:params => 
                                             {:fields => ['name', 'id', 'picture'], :access_token => @service.access_token}}).and_return(@web_mock)
                                             @service.save_friends
      end

      it 'creates a service user objects' do
        lambda{
          @service.save_friends
        }.should change(ServiceUser, :count).by(2)
      end
    end

    describe '#finder' do
      it 'dispatches a resque job' do
        Resque.should_receive(:enqueue).with(Job::UpdateServiceUsers, @service.id)
        @service.finder
      end
      context 'opts' do
        it 'only local does not return people who are remote' do
          @service.save_friends
          @service.finder(:local => true).all.each{|su| su.person.should == @user2.person}
        end

        it 'does not return people who are remote' do
          @service.save_friends
          @service.finder(:remote => true).all.each{|su| su.person.should be_nil}
        end

        it 'does not return wrong service objects' do
          su2 = ServiceUser.create(:service => @user2_service, :uid => @user2_fb_id, :name => @user2_fb_name, :photo_url => @user2_fb_photo_url)
          su2.person.should == @user2.person

          @service.finder(:local => true).all.each{|su| su.service.should == @service}
          @service.finder(:remote => true).all.each{|su| su.service.should == @service}
          @service.finder.all.each{|su| su.service.should == @service}
        end
      end
    end
  end
end
