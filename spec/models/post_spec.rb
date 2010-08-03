require File.dirname(__FILE__) + '/../spec_helper'

describe Post do
  before do
    @user = Factory.create(:user, :email => "bob@aol.com")
  end

  describe 'defaults' do
    before do
      WebSocket.stub!(:update_clients)
      @post = Factory.create(:post, :person => nil)
    end

    it "should associate the owner if none is present" do
      @post.person.should == User.owner
    end
  end

  describe "newest" do
    before do
      @person_one = Factory.create(:person, :email => "some@dudes.com")
      @person_two = Factory.create(:person, :email => "other@dudes.com")
      (2..4).each {|n| Blog.create(:title => "title #{n}", :body => "test #{n}", :person => @person_one)}
      (5..8).each { |n| Blog.create(:title => "title #{n}",:body => "test #{n}", :person => @user)}
      (9..11).each { |n| Blog.create(:title => "title #{n}",:body => "test #{n}", :person => @person_two)}

      Factory.create(:status_message)
      Factory.create(:bookmark)
    end
  
    it "should give the most recent blog title and body from owner" do
      blog = Blog.my_newest()
      blog.person.email.should == @user.email
      blog.class.should == Blog
      blog.title.should == "title 8"
      blog.body.should == "test 8"
    end
    
    it "should give the most recent blog body for a given email" do
      blog = Blog.newest_by_email("some@dudes.com")
      blog.person.email.should == @person_one.email
      blog.class.should == Blog
      blog.title.should == "title 4"
      blog.body.should == "test 4"
    end
  end
 
  describe "stream" do 
    before do
      @owner = Factory.build(:user)
      @person_one = Factory.create(:person, :email => "some@dudes.com")
      @person_two = Factory.create(:person, :email => "other@dudes.com")

      Factory.create(:status_message, :message => "puppies", :created_at => Time.now+1, :person => @owner)
      Factory.create(:bookmark, :title => "Reddit", :link => "http://reddit.com", :created_at => Time.now+2, :person => @person_one)
      Factory.create(:status_message, :message => "kittens", :created_at => Time.now+3, :person => @person_two)
      Factory.create(:blog, :title => "Bears", :body => "Bear's body", :created_at => Time.now+4, :person => @owner)
      Factory.create(:bookmark, :title => "Google", :link => "http://google.com", :created_at => Time.now+5, :person => @person_two)
    end

    it "should list child types in reverse chronological order" do
      stream = Post.stream
      stream.count.should == 5
      stream[0].class.should == Bookmark
      stream[1].class.should == Blog
      stream[2].class.should == StatusMessage
      stream[3].class.should == Bookmark
      stream[4].class.should == StatusMessage
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
      message = Factory.create(:status_message, :person => @user)
      (message.to_xml.to_s.include? @user.email).should == true
    end
  end

  describe 'deletion' do
    it 'should delete a posts comments on delete' do
      post = Factory.create(:status_message, :person => @user)
      @user.comment "hey", :on=> post
      post.destroy
      Post.all(:id => post.id).empty?.should == true
      Comment.all(:text => "hey").empty?.should == true
    end
  end
end

