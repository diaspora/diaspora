require File.dirname(__FILE__) + '/../spec_helper'

class MyProcCommand < Base
  def initialize(&block) self.class.send(:define_method, :run, &block) end
end

class MyCacheCommand < Base
  def run; cache 'foo' end
end

describe YARD::Server::Commands::Base do
  describe '#cache' do
    before do
      @command = MyCacheCommand.new(:adapter => mock_adapter, :caching => true)
      @command.request = OpenStruct.new
    end

    it "should not cache if caching == false" do
      File.should_not_receive(:open)
      @command.caching = false
      @command.run
    end
    
    it "should require document root to cache" do
      File.should_not_receive(:open)
      @command.adapter.document_root = nil
      @command.run
    end
    
    it "should cache to path/to/file.html and create directories" do
      FileUtils.should_receive(:mkdir_p).with('/public/path/to')
      File.should_receive(:open).with('/public/path/to/file.html', anything)
      @command.request.path = '/path/to/file.html'
      @command.run
    end
  end
  
  describe '#redirect' do
    it "should return a valid redirection" do
      cmd = MyProcCommand.new { redirect '/foo' }
      cmd.call(mock_request('/foo')).should == 
        [302, {"Content-Type" => "text/html", "Location" => "/foo"}, [""]]
    end
  end
  
  describe '#call' do
    it "should handle a NotFoundError and use message as body" do
      cmd = MyProcCommand.new { raise NotFoundError, "hello world" }
      s, h, b = *cmd.call(mock_request('/foo'))
      s.should == 404
      b.should == ["hello world"]
    end

    it "should not use message as body if not provided in NotFoundError" do
      cmd = MyProcCommand.new { raise NotFoundError }
      s, h, b = *cmd.call(mock_request('/foo'))
      s.should == 404
      b.should == ["Not found: /foo"]
    end

    it "should handle 404 status code from #run" do
      cmd = MyProcCommand.new { self.status = 404 }
      s, h, b = *cmd.call(mock_request('/foo'))
      s.should == 404
      b.should == ["Not found: /foo"]
    end
    
    it "should not override body if status is 404 and body is defined" do
      cmd = MyProcCommand.new { self.body = "foo"; self.status = 404 }
      s, h, b = *cmd.call(mock_request('/bar'))
      s.should == 404
      b.should == ['foo']
    end
    
    it "should handle body as Array" do
      cmd = MyProcCommand.new { self.body = ['a', 'b', 'c'] }
      s, h, b = *cmd.call(mock_request('/foo'))
      b.should == %w(a b c)
    end
    
    it "should allow headers to be defined" do
      cmd = MyProcCommand.new { self.headers['Foo'] = 'BAR' }
      s, h, b = *cmd.call(mock_request('/foo'))
      h['Foo'].should == 'BAR'
    end
  end
end