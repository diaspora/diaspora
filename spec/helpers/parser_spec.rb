require File.dirname(__FILE__) + '/../spec_helper'

include ApplicationHelper 

describe "parser in application helper" do
  before do
    @user = Factory.create(:user, :email => "bob@aol.com")
    @friend =Factory.create(:friend, :email => "bill@gates.com")
  end

  it "should not store posts from me" do
    status_messages = []
    10.times { status_messages << Factory.build(:status_message, :person => @user)}
    xml = Post.build_xml_for(status_messages) 
    store_posts_from_xml(xml) 
    StatusMessage.count.should == 0
  end
  it 'should discard posts where it does not know the type' do
    xml = "<XML>
    <head>
      <sender>
        <email>#{Friend.first.email}</email>
      </sender>
    </head><posts>
      <post><status_message>\n  <message>Here is another message</message>\n  <owner>a@a.com</owner>\n  <snippet>a@a.com</snippet>\n  <source>a@a.com</source>\n</status_message></post> <post><not_a_real_type></not_a_real_type></post> <post><status_message>\n  <message>HEY DUDE</message>\n  <owner>a@a.com</owner>\n  <snippet>a@a.com</snippet>\n  <source>a@a.com</source>\n</status_message></post>
      </posts></XML>"
    store_posts_from_xml(xml)
    Post.count.should == 2
    Post.first.person.email.should == Friend.first.email
  end
  it "should reject xml with no sender" do
    xml = "<XML>
    <head>
    </head><posts>
      <post><status_message>\n  <message>Here is another message</message>\n  <owner>a@a.com</owner>\n  <snippet>a@a.com</snippet>\n  <source>a@a.com</source>\n</status_message></post>
      <post><friend></friend></post>
      <post><status_message>\n  <message>HEY DUDE</message>\n  <owner>a@a.com</owner>\n  <snippet>a@a.com</snippet>\n  <source>a@a.com</source>\n</status_message></post>
      </posts></XML>"
    store_posts_from_xml(xml)
    Post.count.should == 0

  end
  it "should reject xml with a sender not in the database" do
    xml = "<XML>
    <head>
      <sender>
        <email>foo@example.com</email>
      </sender>
    </head><posts>
      <post><status_message>\n  <message>Here is another message</message>\n  <owner>a@a.com</owner>\n  <snippet>a@a.com</snippet>\n  <source>a@a.com</source>\n</status_message></post>
      <post><friend></friend></post>
      <post><status_message>\n  <message>HEY DUDE</message>\n  <owner>a@a.com</owner>\n  <snippet>a@a.com</snippet>\n  <source>a@a.com</source>\n</status_message></post>
      </posts></XML>"
    store_posts_from_xml(xml)
    Post.count.should == 0
  end
  it 'should discard types which are not of type post' do
    xml = "<XML>
    <head>
      <sender>
        <email>#{Friend.first.email}</email>
      </sender>
    </head><posts>
      <post><status_message>\n  <message>Here is another message</message>\n  <owner>a@a.com</owner>\n  <snippet>a@a.com</snippet>\n  <source>a@a.com</source>\n</status_message></post>
      <post><friend></friend></post>
      <post><status_message>\n  <message>HEY DUDE</message>\n  <owner>a@a.com</owner>\n  <snippet>a@a.com</snippet>\n  <source>a@a.com</source>\n</status_message></post>
      </posts></XML>"
    store_posts_from_xml(xml)
    Post.count.should == 2
    Post.first.person.email.should == Friend.first.email
  end


  describe "parsing compliant XML object" do 
    before do
      status_messages = []
      10.times { status_messages << Factory.build(:status_message)}
      @xml = Post.build_xml_for(status_messages) 
    end

    it 'should be able to parse the sender\'s unique id' do
      parse_sender_id_from_xml(@xml).should == @user.email
    end


    it 'should be able to parse the body\'s contents' do
      body = parse_body_contents_from_xml(@xml).to_s
      body.should_not include "<head>"
      body.should_not include "</head>"
      body.should_not include "<posts>"
      body.should_not include "</posts>"
      body.should include "<post>"
      body.should include "</post>"
    end

    it 'should be able to extract all posts to an array' do
      posts = parse_posts_from_xml(@xml)
      posts.is_a?(Array).should be true
      posts.count.should == 10
    end

  end

end

