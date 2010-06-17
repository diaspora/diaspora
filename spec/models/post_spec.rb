require File.dirname(__FILE__) + '/../spec_helper'

describe Post do
  before do
    Factory.create(:user, :email => "bob@aol.com")
  end

  describe 'requirements' do
  end

  describe 'defaults' do
    before do
      @post = Factory.create(:post, :owner => nil, :source => nil, :snippet => nil)    
    end

    it "should add an owner if none is present" do
      @post.owner.should == "bob@aol.com"
    end

    it "should add a source if none is present" do
      @post.source.should == "bob@aol.com"
    end
    
    it "should add a snippet if none is present" do
      @post.snippet.should == "bob@aol.com"
    end
  end

  it "should list child types in reverse chronological order" do
    Factory.create(:status_message, :message => "puppies", :created_at => Time.now+1)
    Factory.create(:bookmark, :title => "Reddit", :link => "http://reddit.com", :created_at => Time.now+2)
    Factory.create(:status_message, :message => "kittens", :created_at => Time.now+3)
    Factory.create(:blog, :title => "Bears", :body => "Bear's body", :created_at => Time.now+4)
    Factory.create(:bookmark, :title => "Google", :link => "http://google.com", :created_at => Time.now+5)

    stream = Post.stream
    stream.count.should == 5
    stream[0].class.should == Bookmark
    stream[1].class.should == Blog
    stream[2].class.should == StatusMessage
    stream[3].class.should == Bookmark
    stream[4].class.should == StatusMessage
  end
end

