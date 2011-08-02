require File.dirname(__FILE__) + '/../spec_helper'

describe YARD::CLI::Help do
  describe '#run' do
    it "should accept 'help command'" do
      CLI::Yardoc.should_receive(:run).with('--help')
      CLI::Help.run('doc')
    end
    
    it "should accept no arguments (lists all commands)" do
      CLI::CommandParser.should_receive(:run).with('--help')
      CLI::Help.run
    end
    
    it "should show all commands if command isn't found" do
      CLI::CommandParser.should_receive(:run).with('--help')
      help = CLI::Help.new
      help.should_receive(:puts).with(/not found/)
      help.run('unknown')
    end
  end
end