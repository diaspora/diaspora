require File.dirname(__FILE__) + '/../../spec_helper'

describe User do

  before do
    @user = Factory.create :user
    @group = @user.group(:name => 'heroes')

    @user2 = Factory.create(:user)
    @group2 = @user2.group(:name => 'losers') 
    friend_users(@user, @group, @user2, @group2)
  end

  it 'should be able to parse and store a status message from xml' do
    status_message = @user2.post :status_message, :message => 'store this!', :to => @group2.id
    person = @user2.person

    xml = status_message.to_diaspora_xml
    @user2.destroy
    status_message.destroy
    StatusMessage.all.size.should == 0
    @user.receive( xml )
    
    Post.all(:person_id => person.id).first.message.should == 'store this!'
    StatusMessage.all.size.should == 1
  end
  
  it 'should not create new groups on message receive' do
    num_groups = @user.groups.size
    
    (0..5).each{ |n|
      status_message = @user2.post :status_message, :message => "store this #{n}!", :to => @group2.id
      xml = status_message.to_diaspora_xml
      @user.receive( xml )
    }

    @user.groups.size.should == num_groups
  end

  describe 'post refs' do
    before do
      @user3 = Factory.create(:user)
      @group3 = @user3.group(:name => 'heroes')
    end
    
    it "should add the post to that user's posts when a user posts it" do
      status_message = @user.post :status_message, :message => "hi", :to => @group.id
      @user.reload
      @user.raw_visible_posts.include?(status_message).should be true
    end

    it 'should be removed on unfriending' do
      status_message = @user2.post :status_message, :message => "hi", :to => @group2.id
      @user.receive status_message.to_diaspora_xml
      @user.reload

      @user.raw_visible_posts.count.should == 1
      
      @user.unfriend(@user2.person)

      @user.reload
      @user.raw_visible_posts.count.should == 0
      
      Post.count.should be 1
    end

    it 'should be remove a post if the noone links to it' do
      status_message = @user2.post :status_message, :message => "hi", :to => @group2.id
      @user.receive status_message.to_diaspora_xml
      @user.reload

      @user.raw_visible_posts.count.should == 1
      
      person = @user2.person
      @user2.destroy
      @user.unfriend(person)

      @user.reload
      @user.raw_visible_posts.count.should == 0
      
      Post.count.should be 0
    end

    it 'should keep track of user references for one person ' do
      status_message = @user2.post :status_message, :message => "hi", :to => @group2.id
      @user.receive status_message.to_diaspora_xml
      @user.reload

      @user.raw_visible_posts.count.should == 1
      
      status_message.reload
      status_message.user_refs.should == 1
      
      @user.unfriend(@user2.person)
      status_message.reload

      @user.reload
      @user.raw_visible_posts.count.should == 0

      status_message.reload
      status_message.user_refs.should == 0
      
      Post.count.should be 1
    end

    it 'should not override userrefs on receive by another person' do
      @user3.activate_friend(@user2.person, @group3)

      status_message = @user2.post :status_message, :message => "hi", :to => @group2.id
      @user.receive status_message.to_diaspora_xml

      @user3.receive status_message.to_diaspora_xml
      @user.reload
      @user3.reload

      @user.raw_visible_posts.count.should == 1
      
      status_message.reload
      status_message.user_refs.should == 2
      
      @user.unfriend(@user2.person)
      status_message.reload

      @user.reload
      @user.raw_visible_posts.count.should == 0

      status_message.reload
      status_message.user_refs.should == 1
      
      Post.count.should be 1
    end
  end
end
