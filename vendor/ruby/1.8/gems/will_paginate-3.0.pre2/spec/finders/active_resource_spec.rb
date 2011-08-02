require 'spec_helper'
require 'will_paginate/finders/active_resource'
require 'active_resource/http_mock'

class AresProject < ActiveResource::Base
  self.site = 'http://localhost:4000'
end

describe WillPaginate::Finders::ActiveResource do
  
  before :all do
    # ActiveResource::HttpMock.respond_to do |mock|      
    #   mock.get "/ares_projects.xml?page=1&per_page=5", {}, [].to_xml
    # end
  end
  
  it "should integrate with ActiveResource::Base" do
    ActiveResource::Base.should respond_to(:paginate)
  end
  
  it "should error when no parameters for #paginate" do
    lambda { AresProject.paginate }.should raise_error(ArgumentError)
  end
  
  it "should paginate" do
    AresProject.expects(:find_every).with(:params => { :page => 1, :per_page => 5 }).returns([])
    AresProject.paginate(:page => 1, :per_page => 5)
  end
  
  it "should have 30 per_page as default" do
    AresProject.expects(:find_every).with(:params => { :page => 1, :per_page => 30 }).returns([])
    AresProject.paginate(:page => 1)
  end
  
  it "should support #paginate(:all)" do
    lambda { AresProject.paginate(:all) }.should raise_error(ArgumentError)
  end
  
  it "should error #paginate(:other)" do
    lambda { AresProject.paginate(:first) }.should raise_error(ArgumentError)
  end
  
  protected
  
    def create(page = 2, limit = 5, total = nil, &block)
      if block_given?
        WillPaginate::Collection.create(page, limit, total, &block)
      else
        WillPaginate::Collection.new(page, limit, total)
      end
    end  
end
