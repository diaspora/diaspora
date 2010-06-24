require File.dirname(__FILE__) + '/../spec_helper'

describe Post do
  before do
    Factory.create(:user, :email => "bob@aol.com")
  end

  describe 'defaults' do
    before do
      WebSocket.stub!(:update_clients)
      @post = Factory.create(:post, :person => nil)
    end

    it "should associate the owner if none is present" do
      @post.person.should == User.first
    end

  end


  describe "stream" do 
    before do
      @owner = Factory.create(:user, :email => "robert@grimm.com")
      @friend_one = Factory.create(:friend, :email => "some@dudes.com")
      @friend_two = Factory.create(:friend, :email => "other@dudes.com")

      Factory.create(:status_message, :message => "puppies", :created_at => Time.now+1, :person => @owner)
      Factory.create(:bookmark, :title => "Reddit", :link => "http://reddit.com", :created_at => Time.now+2, :person => @friend_one)
      Factory.create(:status_message, :message => "kittens", :created_at => Time.now+3, :person => @friend_two)
      Factory.create(:blog, :title => "Bears", :body => "Bear's body", :created_at => Time.now+4, :person => @owner)
      Factory.create(:bookmark, :title => "Google", :link => "http://google.com", :created_at => Time.now+5, :person => @friend_two)
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
      friend_posts = @friend_one.posts
      friend_posts.count.should == 1

      friend_posts = @friend_two.posts
      friend_posts.count.should == 2
    end
  end

end

