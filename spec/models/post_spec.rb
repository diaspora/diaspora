require File.dirname(__FILE__) + '/../spec_helper'

describe Post do
  before do
    @user = Factory.create(:user, :email => "bob@aol.com")
    @user.person.save
  end

  describe "newest" do
    before do
      @person_one = Factory.create(:person, :email => "some@dudes.com")
      @person_two = Factory.create(:person, :email => "other@dudes.com")
      (2..4).each  { |n| Factory.create(:status_message, :message => "test #{n}", :person => @person_one) }
      (5..8).each  { |n| Factory.create(:status_message, :message => "test #{n}", :person => @user.person)}
      (9..11).each { |n| Factory.create(:status_message, :message => "test #{n}", :person => @person_two) }

      Factory.create(:status_message, :person => @user)
      Factory.create(:status_message, :person => @user)
    end
  
    it "should give the most recent status_message title and body from owner" do
      status_message = StatusMessage.newest_for(@user.person)
      status_message.person.email.should == @user.person.email
      status_message.class.should == StatusMessage
      status_message.message.should == "test 8"
    end

  end
 
  describe "stream" do 
    before do
      @owner      = Factory.build(:user)
      @person_one = Factory.create(:person, :email => "some@dudes.com")
      @person_two = Factory.create(:person, :email => "other@dudes.com")

      Factory.create(:status_message, :message => "puppies", :created_at => Time.now+1, :person => @owner.person)
      Factory.create(:status_message, :message => "http://reddit.com", :created_at => Time.now+2, :person => @person_one)
      Factory.create(:status_message, :message => "kittens", :created_at => Time.now+3, :person => @person_two)
      Factory.create(:status_message, :message => "Bear's body", :created_at => Time.now+4, :person => @owner.person)
      Factory.create(:status_message, :message => "Google", :created_at => Time.now+5, :person => @person_two)
    end

    it "should get all posts for a specified user" do
      person_posts = @person_one.posts
      person_posts.count.should == 1

      person_posts = @person_two.posts
      person_posts.count.should == 2
    end
  end
  describe 'xml' do
    it 'should serialize to xml with its person' do
      message = Factory.create(:status_message, :person => @user.person)
      message.to_xml.to_s.include?(@user.person.email).should == true
    end
  end

  describe 'deletion' do
    it 'should delete a posts comments on delete' do
      post = Factory.create(:status_message, :person => @user.person)
      @user.comment "hey", :on => post
      post.destroy
      Post.all(:id => post.id).empty?.should == true
      Comment.all(:text => "hey").empty?.should == true
    end
  end
end

