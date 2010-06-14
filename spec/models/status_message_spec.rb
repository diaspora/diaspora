require File.dirname(__FILE__) + '/../spec_helper'

describe StatusMessage do
  it "should have a message" do    
    n = StatusMessage.new
    n.valid?.should be false
    n.message = "wales"
    n.valid?.should be true
  end
  
  describe "XML" do
    before do
      @xml = "<statusmessage>\n  <message>I hate WALRUSES!</message>\n</statusmessage>" 
    end
      
    it 'should serialize to XML' do
      message = StatusMessage.new(:message => "I hate WALRUSES!")
      message.to_xml.to_s.should == @xml
    end
  
    it 'should marshal serialized XML to object' do       
      StatusMessage.from_xml(@xml).message.should == "I hate WALRUSES!"
    end
  end
end
