require File.dirname(__FILE__) + '/../spec_helper'
include StatusMessagesHelper

describe StatusMessage do
  before do
      Factory.create(:user, :email => "bob@aol.com", :password => "diggity")
  end

  it "should have a message" do    
    n = Factory.build(:status_message, :message => nil)
    n.valid?.should be false
    n.message = "wales"
    n.valid?.should be true
  end
  
  it "should add an owner if none is present" do
    n = Factory.create(:status_message)    
    n.owner.should == "bob@aol.com"
  end
   
  describe "newest" do
    before do
      (1..5).each { Factory.create(:status_message, :owner => "some@dudes.com") }
      (6..10).each { Factory.create(:status_message) }
    end
    
    it "should give the most recent message from owner" do
      StatusMessage.my_newest.message.should == "jimmy's 11 whales"
    end
    
    it "should give the most recent message for a given email" do
      StatusMessage.newest("some@dudes.com").message.should == "jimmy's 16 whales"
    end
  end
  
  describe "XML" do
    it 'should serialize to XML' do
      message = Factory.create(:status_message, :message => "I hate WALRUSES!")
      message.to_xml.to_s.should include "<message>I hate WALRUSES!</message>"
    end
  
    it 'should marshal serialized XML to object' do       
      xml = "<statusmessage>\n  <message>I hate WALRUSES!</message><owner>Bob@rob.ert</owner></statusmessage>" 
      parsed = StatusMessage.from_xml(xml)
      parsed.message.should == "I hate WALRUSES!"
      parsed.owner.should == "Bob@rob.ert"
      parsed.valid?.should be_true
    end
  end

  describe "retrieving" do
    before do
      @remote = Factory.create(:friend, :url => "fakeurl")#http://localhost:1254/")
      Curl.stub!(:curl).and_return(@@remote_xml)
    end
    it "should marshal xml and serialize it without error" do
      StatusMessages.from_xml(@@remote_xml).to_xml.to_s.should == @@remote_xml
    end
    it "marshal retrieved xml" do
      remote_msgs = StatusMessage.retrieve_from_friend(@remote)
      local_msgs = StatusMessages.from_xml(@@remote_xml)
      remote_msgs.statusmessages.each{ |m| local_msgs.statusmessages.include?(m).should be_true}
      local_msgs.statusmessages.each{ |m| remote_msgs.statusmessages.include?(m).should be_true}
    end
  end
end

@@remote_xml = 
"<statusmessages>
  <statusmessage>
    <message>jimmy's 22 whales</message>
    <owner>tester@yahoo.com</owner>
  </statusmessage>
  <statusmessage>
    <message>jimmy's 23 whales</message>
    <owner>tester@yahoo.com</owner>
  </statusmessage>
  <statusmessage>
    <message>jimmy's 24 whales</message>
    <owner>tester@yahoo.com</owner>
  </statusmessage>
  <statusmessage>
    <message>jimmy's 25 whales</message>
    <owner>tester@yahoo.com</owner>
  </statusmessage>
  <statusmessage>
    <message>jimmy's 26 whales</message>
    <owner>tester@yahoo.com</owner>
  </statusmessage>
</statusmessages>"
