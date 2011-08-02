require File.dirname(__FILE__) + '/spec_helper'

describe YARD::Server::StaticCaching do
  include StaticCaching
  
  describe '#check_static_cache' do
    def adapter; @adapter ||= mock_adapter end
    def request; @request ||= OpenStruct.new end

    it "should return nil if document root is not set" do
      adapter.document_root = nil
      check_static_cache.should be_nil
    end
    
    it "should read a file from document root if path matches file on system" do
      request.path = '/hello/world.html'
      File.should_receive(:file?).with('/public/hello/world.html').and_return(true)
      File.should_receive(:open).with('/public/hello/world.html', anything).and_return('body')
      s, h, b = *check_static_cache
      s.should == 200
      b.should == ["body"]
    end
    
    it "should read a file if path matches file on system + .html" do
      request.path = '/hello/world'
      File.should_receive(:file?).with('/public/hello/world.html').and_return(true)
      File.should_receive(:open).with('/public/hello/world.html', anything).and_return('body')
      s, h, b = *check_static_cache
      s.should == 200
      b.should == ["body"]
    end
    
    it "should return nil if no matching file is found" do
      request.path = '/hello/foo'
      File.should_receive(:file?).with('/public/hello/foo.html').and_return(false)
      check_static_cache.should == nil
    end
  end
end