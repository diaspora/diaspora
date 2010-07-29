require File.dirname(__FILE__) + '/../spec_helper'

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

  it 'should be able to unsubscribe from a status.net user' do
    @user = Factory.create(:user)
    author = Factory.create(:author)
    Author.all.count.should == 1
    q = Request.send :class_variable_get, :@@queue
    q.stub!(:add_hub_unsubscribe_request)
    q.should_receive(:add_hub_unsubscribe_request)

    @user.unsubscribe_from_pubsub(author.id)  
    Author.all.count.should == 0
  end
  
  it 'should be able to update their profile and send it to their friends' do 
    Factory.create(:person)
    p = {:profile => {:first_name => 'bob', :last_name => 'billytown', :image_url => "http://clowntown.com"}}
    
    @user = Factory.create(:user)
     p = {:profile => {:first_name => 'bob', :last_name => 'billytown', :image_url => "http://clown.com"}}
    
    
    @user.update_profile(p).should == true
    
    @user.profile.image_url.should == "http://clown.com"
    
    Profile.should_receive(:build_xml_for)
    
    n = Profile.send :class_variable_get, :@@queue
    n.should_receive(:process)
  end
  

end
