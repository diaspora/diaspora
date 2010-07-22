require 'spec_helper'

describe User do
  it "should be a person" do
    n = Person.count
    Factory.create(:user)
    Person.count.should == n+1
  end

  it "should be able to accept a pending friend request" do
    @user = Factory.create(:user)
    @friend = Factory.create(:person, :active => false)
    r = Request.instantiate(:to => @user.url, :from => @friend)
    r.save
    Person.all.count.should == 2
    Request.for_user(@user).all.count.should == 1
    @user.accept_friend_request(r.id)
    Request.for_user(@user).all.count.should == 0
    Person.where(:id => @friend.id).first.active.should == true
  end

  it 'should be able to ignore a pending friend request' do
    @user = Factory.create(:user)
    @friend = Factory.create(:person, :active => false)
    r = Request.instantiate(:to => @user.url, :from => @friend)
    r.save

    Person.count.should == 2
    @friend.active.should == false

    @user.ignore_friend_request(r.id)

    Person.count.should == 1
    Request.count.should == 0
  end

  it 'should not be able to friend request an existing friend' do
    @user = Factory.create(:user)
    @friend = Factory.create(:person)

    @user.send_friend_request_to( @friend.url ).should be nil
  end

  it 'should be able to give me the terse url for webfinger' do
    user = Factory.create(:user)
    user.terse_url.should == 'example.com'
  end

  
  it 'should subscribe to a status.net user' do
    @user = Factory.create(:user)
    @user.request_connection

    
    #@user.send_friend_request(url)
      @user.send_subscription(url)
        get stream  <== schedule async get  :inquire_subscription
        { 
          parse out hub
          subscribe to hub => s        
          parse_profile
          parse_messages
        
        }
      end
  end
=end

end
