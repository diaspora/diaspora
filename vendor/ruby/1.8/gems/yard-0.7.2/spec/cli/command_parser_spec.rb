require File.dirname(__FILE__) + '/../spec_helper'

describe YARD::CLI::CommandParser do
  describe '#run' do
    before do
      @cmd = CLI::CommandParser.new
    end
    
    it "should show help if --help is provided" do
      command = mock(:command)
      command.should_receive(:run).with('--help')
      CLI::CommandParser.commands[:foo] = command
      @cmd.class.default_command = :foo
      @cmd.run *%w( foo --help )
    end
    
    it "should use default command if first argument is a switch" do
      command = mock(:command)
      command.should_receive(:run).with('--a', 'b', 'c')
      CLI::CommandParser.commands[:foo] = command
      @cmd.class.default_command = :foo
      @cmd.run *%w( --a b c )
    end
    
    it "should use default command if no arguments are provided" do
      command = mock(:command)
      command.should_receive(:run)
      CLI::CommandParser.commands[:foo] = command
      @cmd.class.default_command = :foo
      @cmd.run
    end
    
    it "should list commands if command is not found" do
      @cmd.should_receive(:list_commands)
      @cmd.run *%w( unknown_command --args )
    end

    it "should list commands if --help is provided as sole argument" do
      @cmd.should_receive(:list_commands)
      @cmd.run *%w( --help )
    end
  end
end