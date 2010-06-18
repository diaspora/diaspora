require File.dirname(__FILE__) + '/../spec_helper'

include ApplicationHelper 

describe DashboardHelper do
  before do
    Factory.create(:user) 
  end

  it "should store objects sent from xml" do
    status_messages = []
    10.times { status_messages << Factory.build(:status_message)}
    
    xml = Post.build_xml_for(status_messages) 
    
    store_posts_from_xml(xml) 
    StatusMessage.count.should == 10
  end


end
