require File.dirname(__FILE__) + '/../spec_helper'

describe Post do
  before do
    Factory.create(:user, :email => "bob@aol.com")
    @post = Factory.create(:post, :owner => nil, :source => nil, :snippet => nil)    
  end

  describe 'requirements' do
  end

  describe 'defaults' do

    it "should add an owner if none is present" do
      @post.owner.should == "bob@aol.com"
    end

    it "should add a source if none is present" do
      @post.source.should == "bob@aol.com"
    end
    
    it "should add a snippet if none is present" do
      @post.snippet.should == "bob@aol.com"
    end
  end
end

#question!
#STI ?  do i need to call mongoid doc on child?
# validations inherit?
# type param.
# inheriting snippet builder method
