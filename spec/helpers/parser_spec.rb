require File.dirname(__FILE__) + '/../spec_helper'

include ApplicationHelper 

describe ApplicationHelper do
  before do
    Factory.create(:user) 
  end

  it "should store objects sent from xml" do
    status_messages = []
    10.times { status_messages << Factory.build(:status_message)}
    
    xml = Post.build_xml_for(status_messages) 
    
    store_posts_from_xml(xml) 
    StatusMessage.count.should == 10
  end

  it 'should discard posts where it does not know the type' do
    xml = "<XML><posts>
      <post><status_message>\n  <message>Here is another message</message>\n  <owner>a@a.com</owner>\n  <snippet>a@a.com</snippet>\n  <source>a@a.com</source>\n</status_message></post>
      <post><not_a_real_type></not_a_real_type></post>
      <post><status_message>\n  <message>HEY DUDE</message>\n  <owner>a@a.com</owner>\n  <snippet>a@a.com</snippet>\n  <source>a@a.com</source>\n</status_message></post>
      </posts></XML>"
    store_posts_from_xml(xml)
    Post.count.should == 2
  end

  it 'should discard types which are not of type post' do
    xml = "<XML><posts>
      <post><status_message>\n  <message>Here is another message</message>\n  <owner>a@a.com</owner>\n  <snippet>a@a.com</snippet>\n  <source>a@a.com</source>\n</status_message></post>
      <post><friend></friend></post>
      <post><status_message>\n  <message>HEY DUDE</message>\n  <owner>a@a.com</owner>\n  <snippet>a@a.com</snippet>\n  <source>a@a.com</source>\n</status_message></post>
      </posts></XML>"
    store_posts_from_xml(xml)
    Post.count.should == 2
  end


  describe "parsing a sender" do 
    it 'should be able to parse the sender of a collection' do
    status_messages = []
    10.times { status_messages << Factory.build(:status_message)}
    xml = Post.build_xml_for(status_messages) 
    end

    it 'should be able to verify the sender as a friend' do 
      pending 
    end

  end

end

