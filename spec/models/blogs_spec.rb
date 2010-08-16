require File.dirname(__FILE__) + '/../spec_helper'

describe Blog do
  before do
    @user = Factory.create(:user, :email => "bob@aol.com")
  end

  it "should have a title and body" do    
    n = Blog.new
    n.valid?.should be false
    n.title = "jimmy"
    n.valid?.should be false
    n.body = "wales"
    n.valid?.should be true
  end
  
  
 
  describe "XML" do
    it 'should serialize to XML' do
      body = Factory.create(:blog, :title => "yessir", :body => "penguins", :person => @user.person)
      body.to_xml.to_s.should include "<title>yessir</title>"
      body.to_xml.to_s.should include "<body>penguins</body>"
    end
  
    it 'should marshal serialized XML to object' do       
      xml = "<blog>\n  <title>yessir</title>\n  <body>I hate WALRUSES!</body>\n</blog>" 
      parsed = Blog.from_xml(xml)
      parsed.body.should == "I hate WALRUSES!"
    end
  end
end
