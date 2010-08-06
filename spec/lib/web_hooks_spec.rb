require File.dirname(__FILE__) + '/../spec_helper'

include Diaspora

describe Diaspora do

  describe Webhooks do
    before do
      @user = Factory.create(:user, :email => "bob@aol.com")
      @user.person.save
      @person = Factory.create(:person)
    end

    describe "body" do
      before do
        @post = Factory.build(:status_message, :person => @user.person)
      end

      it "should add the following methods to Post on inclusion" do
        @post.respond_to?(:notify_people).should be true
        @post.respond_to?(:to_diaspora_xml).should be true
        @post.respond_to?(:people_with_permissions).should be true
      end

      it "should convert an object to a proper diaspora entry" do
        @post.to_diaspora_xml.should == "<post>#{@post.to_xml.to_s}</post>"
      end

      it "should retrieve all valid person endpoints" do
        @user.friends << Factory.create(:person, :url => "http://www.bob.com/")
        @user.friends << Factory.create(:person, :url => "http://www.alice.com/")
        @user.friends << Factory.create(:person, :url => "http://www.jane.com/")
        @user.save

        @post.person.owner.reload
                
        @post.people_with_permissions.should == @user.friends
      end

      it "should send an owners post to their people" do
        q = Post.send(:class_variable_get, :@@queue)      
        q.should_receive :process
        @user.post :status_message, :message => "hi" 
        @post.save
      end
    
      it "should check that it does not send a person's post to an owners people" do
        Post.stub(:build_xml_for).and_return(true) 
        Post.should_not_receive(:build_xml_for)
        
        Factory.create(:status_message, :person => Factory.create(:person))
      end

      it "should ensure one url is created for every person" do
        5.times {@user.friends << Factory.create(:person)}
        @user.save
        
        @post.person.owner.reload
        
        @post.people_with_permissions.size.should == 5
      end

      it "should build an xml object containing multiple Post types" do
        Factory.create(:status_message)
        Factory.create(:bookmark)

        stream = Post.stream
        xml = Post.build_xml_for(stream)
        xml.should include "<status_message>"
        xml.should include "<bookmark>"
      end
    end
  end

end
