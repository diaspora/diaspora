require File.dirname(__FILE__) + '/../spec_helper'

describe User do
   before do
      @user = Factory.create(:user)
   end

  it "should be a person" do
    n = Person.count
    Factory.create(:user)
    Person.count.should == n+1
  end
  
  describe 'friend requesting' do
     it "should be able to accept a pending friend request" do
      friend = Factory.create(:person)
      r = Request.instantiate(:to => @user.url, :from => friend)
      r.save
      Person.all.count.should == 2
      Request.for_user(@user).all.count.should == 1
      @user.accept_friend_request(r.id)
      Request.for_user(@user).all.count.should == 0
      #Person.where(:id => friend.id).first.active.should == true
    end

    it 'should be able to ignore a pending friend request' do
      friend = Factory.create(:person)
      r = Request.instantiate(:to => @user.url, :from => friend)
      r.save

      Person.count.should == 2
      #friend.active.should == false

      @user.ignore_friend_request(r.id)

      Person.count.should == 1
      Request.count.should == 0
    end

    it 'should not be able to friend request an existing friend' do
      friend = Factory.create(:person)
      
      @user.friends << friend
      @user.save


      @user.send_friend_request_to( friend.url ).should be nil
    end

    it 'should be able to give me the terse url for webfinger' do
     @user.person.url = "http://example.com/"

      @user.terse_url.should == 'example.com'
    end

    it 'should get the pending friends' do
      person_one = Factory.create :person
      person_two = Factory.create :person
      @user.pending_requests.empty?.should be true
      @user.friends.empty?.should be true

      request = Request.instantiate(:to => @user.url, :from => person_one)
      person_one.destroy
      @user.receive_friend_request request
      @user.pending_requests.size.should be 1
      @user.friends.size.should be 0
      
      request_two = Request.instantiate(:to => @user.url, :from => person_two)
      person_two.destroy
      @user.receive_friend_request request_two
      @user.pending_requests.size.should be 2
      @user.friends.size.should be 0

      @user.accept_friend_request request.id
      @user.pending_requests.size.should be 1
      @user.friends.size.should be 1
 
      @user.ignore_friend_request request_two.id
      @user.pending_requests.size.should be 0
      @user.friends.size.should be 1
    end
  end

  describe 'profiles' do
    it 'should be able to update their profile and send it to their friends' do 
      Factory.create(:person)
      
      updated_profile = {:profile => {:first_name => 'bob', :last_name => 'billytown', :image_url => "http://clown.com"}}
      
      message_queue.should_receive(:process)
      
      @user.person.update_profile(updated_profile).should == true
      @user.profile.image_url.should == "http://clown.com"
    end
  end
end
