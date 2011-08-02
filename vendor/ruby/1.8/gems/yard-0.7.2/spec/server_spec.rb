require File.dirname(__FILE__) + "/spec_helper"

describe YARD::Server do
  describe '.register_static_path' do
    it "should register a static path" do
      YARD::Server.register_static_path 'foo'
      YARD::Server::Commands::StaticFileCommand::STATIC_PATHS.last.should == "foo"
    end
  end
end