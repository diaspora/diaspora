require File.dirname(__FILE__) + '/../spec_helper'

include ApplicationHelper 
include Diaspora::Parser



describe Diaspora::Parser do
  before do
    @user = Factory.create(:user, :email => "bob@aol.com")
    @group = @user.group(:name => 'spies')
    @person = Factory.create(:person_with_private_key, :email => "bill@gates.com")
    @user2 = Factory.create(:user)
  end


  it "should associate the post with a group" do
    @user.activate_friend(@person, @group)

    status_message = Factory.build(:status_message, :message => "hey!", :person => @person)
    @user.receive status_message.to_diaspora_xml
    @user.posts.count.should == 1
  end



  describe 'with encryption' do
    before do
      unstub_mocha_stubs
    end
    after do
      stub_signature_verification
    end
    it "should not store posts from me" do
      10.times { 
        message = Factory.build(:status_message, :person => @user)
        xml = message.to_diaspora_xml
        @user.receive xml 
        }
      StatusMessage.count.should == 0
    end
    
    it "should reject xml with no sender" do
      xml = "<XML>
      <head>
      </head>
        <post><status_message>\n  <message>Here is another message</message>\n  <owner>a@a.com</owner>\n  <snippet>a@a.com</snippet>\n  <source>a@a.com</source>\n</status_message></post>
        <post><person></person></post>
        <post><status_message>\n  <message>HEY DUDE</message>\n  <owner>a@a.com</owner>\n  <snippet>a@a.com</snippet>\n  <source>a@a.com</source>\n</status_message></post>
        </XML>"
      @user.receive xml
      Post.count.should == 0
    end
  end 

  describe "parsing compliant XML object" do 
    before do
      @xml = Factory.build(:status_message).to_diaspora_xml 
    end
    
    it 'should be able to correctly handle comments' do
      person = Factory.create(:person, :email => "test@testing.com")
      post = Factory.create(:status_message, :person => @user.person)
      comment = Factory.build(:comment, :post => post, :person => person, :text => "Freedom!")
      xml = comment.to_diaspora_xml 

      comment = Diaspora::Parser.from_xml(xml)
      comment.text.should == "Freedom!"
      comment.person.should == person
      comment.post.should == post
    end
    
    it 'should marshal retractions' do
      person = Factory.create(:person)
      message = Factory.create(:status_message, :person => person)
      retraction = Retraction.for(message)
      request = retraction.to_diaspora_xml

      StatusMessage.count.should == 1
      @user.receive request
      StatusMessage.count.should == 0
    end
    
    it "should create a new person upon getting a person request" do
      person_count = Person.all.count
      request = Request.instantiate(:to =>"http://www.google.com/", :from => @person)
      
      original_person_id = @person.id
      xml = request.to_diaspora_xml 
      
      @person.destroy
      Person.all.count.should == person_count -1
      @user.receive xml
      Person.all.count.should == person_count

      Person.first(:_id => original_person_id).serialized_key.include?("PUBLIC").should be true
      url = "http://" + request.callback_url.split("/")[2] + "/"
      Person.where(:url => url).first.id.should == original_person_id
    end
    
    it "should not create a new person if the person is already here" do
      person_count = Person.all.count
      request = Request.instantiate(:to =>"http://www.google.com/", :from => @user2.person)
      
      original_person_id = @user2.person.id
      xml = request.to_diaspora_xml
      
      
      Person.all.count.should be person_count
      @user.receive xml
      Person.all.count.should be person_count
      
      @user2.reload
      @user2.person.reload
      @user2.person.serialized_key.include?("PRIVATE").should be true

      url = "http://" + request.callback_url.split("/")[2] + "/"
      Person.where(:url => url).first.id.should == original_person_id
    end

    it "should activate the Person if I initiated a request to that url" do 
      request = @user.send_friend_request_to( @user2.receive_url, @group.id)

      request.reverse @user2 

      xml = request.to_diaspora_xml 

      @user2.person.destroy
      @user2.destroy

      @user.receive xml
      new_person = Person.first(:url => @user2.person.url)
      new_person.nil?.should be false
      
      @user.reload
      @group.reload
      @group.people.include?(new_person).should be true
      @user.friends.include?(new_person).should be true
    end


    it 'should process retraction for a person' do
      person_count = Person.all.count
      request = @user.send_friend_request_to( @user2.receive_url, @group.id)
      request.reverse @user2 
      xml = request.to_diaspora_xml 

      retraction = Retraction.for(@user2)
      retraction_xml = retraction.to_diaspora_xml
      
      @user2.person.destroy
      @user2.destroy
      @user.receive xml
      
      @group.reload
      group_people_count = @group.people.size
      #They are now friends


      Person.count.should == person_count
      @user.receive retraction_xml
      Person.count.should == person_count-1

      @group.reload
      @group.people.size.should == group_people_count -1
    end
    
    it 'should marshal a profile for a person' do
      #Create person
      person = Factory.create(:person)
      id = person.id
      person.profile = Profile.new(:first_name => 'bob', :last_name => 'billytown', :image_url => "http://clown.com")
      person.save

      #Cache profile for checking against marshaled profile
      old_profile = person.profile
      old_profile.first_name.should == 'bob'

      #Build xml for profile, clear profile
      xml = person.profile.to_diaspora_xml
      reloaded_person = Person.first(:id => id)            
      reloaded_person.profile = nil
      reloaded_person.save(:validate => false)

      #Make sure profile is cleared
      Person.first(:id => id).profile.should be nil    
      old_profile.first_name.should == 'bob'

      #Marshal profile
      @user.receive xml
      
      #Check that marshaled profile is the same as old profile
      person = Person.first(:id => person.id)
      person.profile.should_not be nil 
      person.profile.first_name.should == old_profile.first_name
      person.profile.last_name.should  == old_profile.last_name
      person.profile.image_url.should  == old_profile.image_url
      end
  end
end

