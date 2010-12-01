require File.join(File.dirname(__FILE__),"spec_helper.rb")
require 'stringio'

describe Launchy do
  it "instantiates an instance of Launchy::CommandLine for commandline" do
    Launchy.command_line.class.should eql(Launchy::CommandLine)
  end

  it "logs to stderr when LAUNCHY_DEBUG environment variable is set" do
    ENV["LAUNCHY_DEBUG"] = 'true'
    old_stderr = $stderr
    $stderr = StringIO.new
    Launchy.log "This is a test log message"
    $stderr.string.strip.should eql("LAUNCHY_DEBUG: This is a test log message")
    $stderr = old_stderr
    ENV["LAUNCHY_DEBUG"] = nil
  end
end
