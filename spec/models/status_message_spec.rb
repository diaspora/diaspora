require File.dirname(__FILE__) + '/../spec_helper'

describe StatusMessage do
  before do
      @user = Factory.create(:user, :email => "bob@aol.com")
  end

  it "should have a message" do    
    n = Factory.build(:status_message, :message => nil)
    n.valid?.should be false
    n.message = "wales"
    n.valid?.should be true
  end
   
  
  it "should add an owner if none is present" do
    n = Factory.create(:status_message)    
    n.person.email.should == "bob@aol.com"
  end
   
  describe "newest" do
    before do
      @person_one = Factory.create(:friend,:email => "some@dudes.com")
      (1..10).each { Factory.create(:status_message, :person => @person_one) }
      (1..5).each { Factory.create(:status_message) }
      Factory.create(:bookmark)
      Factory.create(:bookmark, :person => @person_one)
    end
    
    it "should give the most recent message from a friend" do
      StatusMessage.newest(@person_one).message.should ==  "jimmy's 13 whales"
    end
    
    it "should give the most recent message for a given email" do
      StatusMessage.newest_by_email(@person_one.email).message.should ==  "jimmy's 28 whales"
    end
  end
  
  describe "XML" do
    it 'should serialize to XML' do
      message = Factory.create(:status_message, :message => "I hate WALRUSES!")
      message.to_xml.to_s.should include "<message>I hate WALRUSES!</message>"
    end
  
    it 'should marshal serialized XML to object' do       
      xml = "<statusmessage><message>I hate WALRUSES!</message></statusmessage>" 
      parsed = StatusMessage.from_xml(xml)
      parsed.message.should == "I hate WALRUSES!"
      parsed.valid?.should be_true
    end
  end
end

