require File.dirname(__FILE__) + '/../spec_helper'

describe StatusMessage do
  before do
      @usr = Factory.create(:user,:email => "bob@aol.com", :password => "diggity")
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
      (1..5).each {  Factory.create(:status_message, :owner => "some@dudes.com") }
      (6..10).each {  Factory.create(:status_message) }
    end
    
    it "should give the most recent message from owner" do
      #puts StatusMessage.newest("sam@cool.com")
      StatusMessage.my_newest.message.should == "jimmy's 11 whales"
    end
    
    it "should give the most recent message for a given email" do
      StatusMessage.newest("some@dudes.com").message.should == "jimmy's 16 whales"
    end
  end
  
  describe "XML" do
    before do
      @xml = "<statusmessage>\n  <message>I hate WALRUSES!</message>\n  <owner>Bob</owner>\n</statusmessage>" 
    end
      
    it 'should serialize to XML' do
      message = Factory.create(:status_message, :message => "I hate WALRUSES!", :owner => "Bob")
      message.to_xml.to_s.should == @xml
    end
  
    it 'should marshal serialized XML to object' do       
      parsed = StatusMessage.from_xml(@xml)
      parsed.message.should == "I hate WALRUSES!"
      parsed.owner.should == "Bob"
      parsed.valid?.should be_true
    end
  end

  describe "retrieving" do
    before do
      @remote = Factory.create(:friend, :url => "http://localhost:1254/")
      @remote_xml = (0..5).collect{Factory.create(:status_message).to_xml}
      StatusMessages = StatusMessagesHelper::StatusMessages
      #@remote_messages = (0..5).collect {|a| Factory.build(:status_message)}
      #stub with response of @remote_msg.xml
    end
    it "should marshal xml and serialize it" do
      messages = StatusMessages.new(@remote_xml)
      unreadable_xml = messages.to_xml.to_s.sub("\t\t","\t")
      unreadable_xml.include?(remote_xml.first.to_s).should be true
    end
    it "marshal retrieved xml" do
      StatusMessage.retrieve_from_friend(@remote).to_xml.should == StatusMessages.from_xml(@remote_xml).to_xml

        # .from_xml == @remote_messages
    end
  end
end
