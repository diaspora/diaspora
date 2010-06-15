require File.dirname(__FILE__) + '/../spec_helper'

describe StatusMessage do
  it "should have a message" do    
    n = StatusMessage.new
    n.valid?.should be false
    n.message = "wales"
    n.valid?.should be true
  end
  
  it "should add an owner if none is present" do
    User.create(:email => "bob@aol.com", :password => "big bux")
    n = StatusMessage.create(:message => "puppies!")
    n.owner.should == "bob@aol.com"
  end
  
  
  describe "newest" do
    before do
      User.create(:email => "bob@aol.com", :password => "diggity")
      StatusMessage.create(:message => "wale for jimmy", :owner => "xzibit@dawgz.com")
      StatusMessage.create(:message => "jimmy wales")
      StatusMessage.create(:message => "jimmy your wales", :owner => "some@dudes.com")  
      StatusMessage.create(:message => "lions", :owner => "xzibit@dawgz.com")
      StatusMessage.create(:message => "bears")
      StatusMessage.create(:message => "sharks", :owner => "some@dudes.com")
      StatusMessage.create(:message => "roar")
    end
  
    it "should give the most recent message from owner" do
      StatusMessage.my_newest.message.should == "roar"
    end
    
    it "should give the most recent message for a given email" do
      StatusMessage.newest("some@dudes.com").message.should == "sharks"
    end
  end
  
  describe "XML" do
    before do
      @xml = "<statusmessage>\n  <message>I hate WALRUSES!</message>\n  <owner>Bob</owner>\n</statusmessage>" 
    end
      
    it 'should serialize to XML' do
      message = StatusMessage.create(:message => "I hate WALRUSES!", :owner => "Bob")
      message.to_xml.to_s.should == @xml
    end
  
    it 'should marshal serialized XML to object' do       
      parsed = StatusMessage.from_xml(@xml)
      parsed.message.should == "I hate WALRUSES!"
      parsed.owner.should == "Bob"
    end
  end
end
