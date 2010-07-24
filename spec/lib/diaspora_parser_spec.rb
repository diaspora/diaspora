require File.dirname(__FILE__) + '/../spec_helper'

include ApplicationHelper 

describe Diaspora::DiasporaParser do
  before do
    @user = Factory.create(:user, :email => "bob@aol.com")
    @person = Factory.create(:person, :email => "bill@gates.com")
  end

  it "should not store posts from me" do
    status_messages = []
    10.times { status_messages << Factory.build(:status_message, :person => @user)}
    xml = Post.build_xml_for(status_messages) 
    store_objects_from_xml(xml) 
    StatusMessage.count.should == 0
  end
  
  it "should reject xml with no sender" do
    xml = "<XML>
    <head>
    </head><posts>
      <post><status_message>\n  <message>Here is another message</message>\n  <owner>a@a.com</owner>\n  <snippet>a@a.com</snippet>\n  <source>a@a.com</source>\n</status_message></post>
      <post><person></person></post>
      <post><status_message>\n  <message>HEY DUDE</message>\n  <owner>a@a.com</owner>\n  <snippet>a@a.com</snippet>\n  <source>a@a.com</source>\n</status_message></post>
      </posts></XML>"
    store_objects_from_xml(xml)
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
      <post><person></person></post>
      <post><status_message>\n  <message>HEY DUDE</message>\n  <owner>a@a.com</owner>\n  <snippet>a@a.com</snippet>\n  <source>a@a.com</source>\n</status_message></post>
      </posts></XML>"
    store_objects_from_xml(xml)
    Post.count.should == 0
  end
  
  it 'should discard types which are not of type post' do
    xml = "<XML>
    <head>
      <sender>
        <email>#{Person.first.email}</email>
      </sender>
    </head>
    <posts>
      <post><person></person></post>
    </posts></XML>"
    
    store_objects_from_xml(xml)
    Post.count.should == 0
  end


  describe "parsing compliant XML object" do 
    before do
      @status_messages = []
      10.times { @status_messages << Factory.build(:status_message)}
      @xml = Post.build_xml_for(@status_messages) 
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
      posts = parse_objects_from_xml(@xml)
      posts.is_a?(Array).should be true
      posts.count.should == 10
    end
    
    it 'should be able to correctly handle comments' do
      person = Factory.create(:person, :email => "test@testing.com")
      post = Factory.create(:status_message)
      comment = Factory.build(:comment, :post => post, :person => person, :text => "Freedom!")
      xml = "<XML>
      <posts>
        <post>#{comment.to_xml}</post>
      </posts></XML>"

      objects = parse_objects_from_xml(xml)
      comment = objects.first
      comment.text.should == "Freedom!"
      comment.person.should == person
      comment.post.should == post
    end
    
    it 'should marshal retractions' do
      person = Factory.create(:person)
      message = Factory.create(:status_message, :person => person)
      retraction = Retraction.for(message)
      request = Post.build_xml_for( [retraction] )

      StatusMessage.count.should == 1
      store_objects_from_xml( request )
      StatusMessage.count.should == 0
    end
    
    it "should create a new person upon getting a person request" do
      request = Request.instantiate(:to =>"http://www.google.com/", :from => @person)
      
      original_person_id = @person.id
      xml = Request.build_xml_for [request]

      @person.destroy
      Person.all.count.should be 1
      store_objects_from_xml(xml)
      Person.all.count.should be 2

      Person.where(:url => request.callback_url).first.id.should == original_person_id
    end
    

    it "should activate the Person if I initiated a request to that url" do 
      request = Request.instantiate(:to => @person.url, :from => @user).save
      
      request_remote = Request.new
      request_remote.destination_url = @user.url
      request_remote.callback_url = @user.url
      request_remote.person = @person
      request_remote.exported_key = @person.export_key

      xml = Request.build_xml_for [request_remote]
      
      @person.destroy
      request_remote.destroy
      store_objects_from_xml(xml)
      Person.first(:url => @person.url).active.should be true
    end


    it 'should marshal a retraction for a person' do
      retraction = Retraction.for(@user)
      request = Retraction.build_xml_for( [retraction] )

      Person.count.should == 2
      store_objects_from_xml( request )
      Person.count.should == 1

    end
  end
end

