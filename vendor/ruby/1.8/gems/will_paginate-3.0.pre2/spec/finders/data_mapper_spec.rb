require 'spec_helper'
require 'will_paginate/finders/data_mapper'
require File.expand_path('../data_mapper_test_connector', __FILE__)

require 'will_paginate'

describe WillPaginate::Finders::DataMapper do
    
  it "should make #paginate available to DM resource classes" do
    Animal.should respond_to(:paginate)
  end
  
  it "should paginate" do
    Animal.expects(:all).with(:limit => 5, :offset => 0).returns([])
    Animal.paginate(:page => 1, :per_page => 5)
  end
  
  it "should NOT to paginate_by_sql" do
    Animal.should_not respond_to(:paginate_by_sql)
  end
  
  it "should support explicit :all argument" do
    Animal.expects(:all).with(instance_of(Hash)).returns([])
    Animal.paginate(:all, :page => nil)
  end
  
  it "should support conditional pagination" do
    filtered_result = Animal.paginate(:all, :name => 'Dog', :page => nil)
    filtered_result.size.should == 1
    filtered_result.first.should == Animal.first(:name => 'Dog')
  end
  
  it "should leave extra parameters intact" do
    Animal.expects(:all).with(:name => 'Dog', :limit => 4, :offset => 0 ).returns(Array.new(5))
    Animal.expects(:count).with({:name => 'Dog'}).returns(1)
  
    Animal.paginate :name => 'Dog', :page => 1, :per_page => 4
  end

  describe "counting" do
    it "should ignore nil in :count parameter" do
      lambda { Animal.paginate :page => nil, :count => nil }.should_not raise_error
    end
    
    it "should guess the total count" do
      Animal.expects(:all).returns(Array.new(2))
      Animal.expects(:count).never
  
      result = Animal.paginate :page => 2, :per_page => 4
      result.total_entries.should == 6
    end
  
    it "should guess that there are no records" do
      Animal.expects(:all).returns([])
      Animal.expects(:count).never
  
      result = Animal.paginate :page => 1, :per_page => 4
      result.total_entries.should == 0
    end
  end
  
end
