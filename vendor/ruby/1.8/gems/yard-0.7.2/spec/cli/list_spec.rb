require File.dirname(__FILE__) + '/../spec_helper'

describe YARD::CLI::List do
  it "should pass command off to Yardoc with --list" do
    YARD::CLI::Yardoc.should_receive(:run).with('--list', '--foo')
    YARD::CLI::List.run('--foo')
  end
end
