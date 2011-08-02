require File.dirname(__FILE__) + '/../spec_helper'

describe YARD::Server::Commands::StaticFileCommand do
  before do
    adapter = mock_adapter
    adapter.document_root = '/c'
    @cmd = StaticFileCommand.new(:adapter => adapter)
  end
  
  describe '#run' do
    def run(path, status = nil, body = nil)
      s, h, b = *@cmd.call(mock_request(path))
      body.should == b.first if body
      status.should == s if status
      [s, h, b]
    end
    
    it "should search through document root before static paths" do
      File.should_receive(:exist?).with('/c/path/to/file.txt').ordered.and_return(false)
      StaticFileCommand::STATIC_PATHS.reverse.each do |path|
        File.should_receive(:exist?).with(File.join(path, 'path/to/file.txt')).ordered.and_return(false)
      end
      run '/path/to/file.txt'
    end
    
    it "should return file contents if found" do
      path = File.join(StaticFileCommand::STATIC_PATHS.last, '/path/to/file.txt')
      File.should_receive(:exist?).with('/c/path/to/file.txt').and_return(false)
      File.should_receive(:exist?).with(path).and_return(true)
      File.should_receive(:read).with(path).and_return('FOO')
      run('/path/to/file.txt', 200, 'FOO')
    end
    
    it "should allow registering of new paths and use those before other static paths" do
      Server.register_static_path '/foo'
      path = '/foo/path/to/file.txt'
      File.should_receive(:exist?).with('/c/path/to/file.txt').and_return(false)
      File.should_receive(:exist?).with(path).and_return(true)
      File.should_receive(:read).with(path).and_return('FOO')
      run('/path/to/file.txt', 200, 'FOO')
    end

    it "should not use registered path before docroot" do
      Server.register_static_path '/foo'
      path = '/foo/path/to/file.txt'
      File.should_receive(:exist?).with('/c/path/to/file.txt').and_return(true)
      File.should_receive(:read).with('/c/path/to/file.txt').and_return('FOO')
      run('/c/path/to/file.txt', 200, 'FOO')
    end
    
    it "should return 404 if not found" do
      File.should_receive(:exist?).with('/c/path/to/file.txt').ordered.and_return(false)
      StaticFileCommand::STATIC_PATHS.reverse.each do |path|
        File.should_receive(:exist?).with(File.join(path, 'path/to/file.txt')).ordered.and_return(false)
      end
      run('/path/to/file.txt', 404)
    end
    
    it "should return text/html for file with no extension" do
      File.should_receive(:exist?).with('/c/file').and_return(true)
      File.should_receive(:read).with('/c/file')
      s, h, b = *run('/file')
      h['Content-Type'].should == 'text/html'
    end
    
    {
      "js" => "text/javascript",
      "css" => "text/css",
      "png" => "image/png",
      "gif" => "image/gif",
      "htm" => "text/html",
      "html" => "text/html",
      "txt" => "text/plain",
      "unknown" => "application/octet-stream"
    }.each do |ext, mime|
      it "should serve file.#{ext} as #{mime}" do
        File.should_receive(:exist?).with('/c/file.' + ext).and_return(true)
        File.should_receive(:read).with('/c/file.' + ext)
        s, h, b = *run('/file.' + ext)
        h['Content-Type'].should == mime
      end
    end
  end
end