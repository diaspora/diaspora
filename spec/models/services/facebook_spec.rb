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

      stub_request(:post, "https://graph.facebook.com/me/feed").
        to_return(:status => 200)
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
      @service.should_receive(:public_message).with(@post, url)
      @service.post(@post, url)
    end
  end
  
  describe '#create_post_params' do
    it 'should have a link when the message has a link' do
      @service.create_post_params("http://example.com/ test message")[:link].should == "http://example.com/"
    end
    it 'should not have a link when the message has no link' do
      @service.create_post_params("test message")[:link].should == nil
    end
  end

  context 'finder' do
    before do
      @user2 = Factory(:user_with_aspect)
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
      stub_request(:get, "https://graph.facebook.com/me/friends?fields[]=name&fields[]=picture&access_token=yeah").
        to_return(:body => @fb_list_hash)
    end

    describe '#save_friends' do
      it 'requests a friend list' do
        @service.save_friends
        WebMock.should have_requested(:get, "https://graph.facebook.com/me/friends?fields[]=name&fields[]=picture&access_token=yeah")
      end

      it 'creates a service user objects' do
        lambda{
          @service.save_friends
        }.should change(ServiceUser, :count).by(2)
      end

      it 'attaches local models' do
        @service.save_friends
        @service.service_users.where(:uid => @user2_fb_id).first.person.should == @user2.person
      end

      it 'overwrites local model information' do
        @service.save_friends
        su = @service.service_users.where(:uid => @user2_fb_id).first
        su.person.should == @user2.person
        su.contact.should == nil

        connect_users_with_aspects(alice, @user2)
        @service.save_friends
        su.person.should == @user2.person
        su.reload.contact.should == alice.contact_for(@user2.person)
      end
    end

    describe '#finder' do
      it 'does a synchronous call if it has not been called before' do
        Resque.should_receive(:enqueue).with(Jobs::UpdateServiceUsers, @service.id)
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
          @service.finder.each{|su| su.service.should == @service}
        end
      end
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
