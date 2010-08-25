require File.dirname(__FILE__) + '/../spec_helper'

describe StatusMessage do
  before do
      @user = Factory.create(:user, :email => "bob@aol.com")
      @group = @user.group(:name => "losers")
  end

  it "should have a message" do    
    n = Factory.build(:status_message, :message => nil)
    n.valid?.should be false
    n.message = "wales"
    n.valid?.should be true
  end
  
  it 'should be postable through the user' do
    status = @user.post(:status_message, :message => "Users do things", :to => @group.id)
  end

  describe "XML" do
    it 'should serialize to XML' do
      message = Factory.create(:status_message, :message => "I hate WALRUSES!", :person => @user.person)
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

