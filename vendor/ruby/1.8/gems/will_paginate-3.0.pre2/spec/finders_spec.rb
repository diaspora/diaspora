require 'spec_helper'
require 'will_paginate/finders/base'

class Model
  extend WillPaginate::Finders::Base
end

describe WillPaginate::Finders::Base do
  it "should define default per_page of 30" do
    Model.per_page.should == 30
  end
  
  it "should allow to set custom per_page" do
    begin
      Model.per_page = 25
      Model.per_page.should == 25
    ensure
      Model.per_page = 30
    end
  end

  it "should result with WillPaginate::Collection" do
    Model.expects(:wp_query)
    Model.paginate(:page => nil).should be_instance_of(WillPaginate::Collection)
  end

  it "should delegate pagination to wp_query" do
    Model.expects(:wp_query).with({}, instance_of(WillPaginate::Collection), [])
    Model.paginate :page => nil
  end

  it "should complain when no hash parameters given" do
    lambda {
      Model.paginate
    }.should raise_error(ArgumentError, 'parameter hash expected')
  end

  it "should complain when no :page parameter present" do
    lambda {
      Model.paginate :per_page => 6
    }.should raise_error(ArgumentError, ':page parameter required')
  end

  it "should complain when both :count and :total_entries are given" do
    lambda {
      Model.paginate :page => 1, :count => {}, :total_entries => 1
    }.should raise_error(ArgumentError, ':count and :total_entries are mutually exclusive')
  end

  it "should never mangle options" do
    options = { :page => 1 }
    options.expects(:delete).never
    options_before = options.dup
    
    Model.expects(:wp_query)
    Model.paginate(options)
    
    options.should == options_before
  end

  it "should provide paginated_each functionality" do
    collection = stub('collection', :size => 5, :empty? => false, :per_page => 5)
    collection.expects(:each).times(2).returns(collection)
    last_collection = stub('collection', :size => 4, :empty? => false, :per_page => 5)
    last_collection.expects(:each).returns(last_collection)
    
    params = { :order => 'id', :total_entries => 0 }
    
    Model.expects(:paginate).with(params.merge(:page => 2)).returns(collection)
    Model.expects(:paginate).with(params.merge(:page => 3)).returns(collection)
    Model.expects(:paginate).with(params.merge(:page => 4)).returns(last_collection)
    
    total = Model.paginated_each(:page => '2') { }
    total.should == 14
  end
end
