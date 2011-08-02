require File.expand_path('../spec_helper', __FILE__)
require "pid_behavior"

if ChildProcess.unix?
  describe ChildProcess::Unix::Process do
    it_behaves_like "a platform that provides the child's pid"

    it "handles ECHILD race condition where process dies between timeout and KILL" do
      process = sleeping_ruby

      process.stub!(:fork).and_return('fakepid')
      process.stub!(:send_term)
      process.stub!(:poll_for_exit).and_raise(ChildProcess::TimeoutError)
      process.stub!(:send_kill).and_raise(Errno::ECHILD)

      process.start
      lambda { process.stop }.should_not raise_error

      process.stub(:alive?).and_return(false)
    end

    it "handles ESRCH race condition where process dies between timeout and KILL" do
      process = sleeping_ruby

      process.stub!(:fork).and_return('fakepid')
      process.stub!(:send_term)
      process.stub!(:poll_for_exit).and_raise(ChildProcess::TimeoutError)
      process.stub!(:send_kill).and_raise(Errno::ESRCH)

      process.start
      lambda { process.stop }.should_not raise_error

      process.stub(:alive?).and_return(false)
    end
  end

  describe ChildProcess::Unix::IO do
    let(:io) { ChildProcess::Unix::IO.new }

    it "raises an ArgumentError if given IO does not respond to :to_io" do
      lambda { io.stdout = nil }.should raise_error(ArgumentError, /to respond to :to_io/)
    end

    it "raises a TypeError if #to_io does not return an IO" do
      fake_io = Object.new
      def fake_io.to_io() StringIO.new end

      lambda { io.stdout = fake_io }.should raise_error(TypeError, /expected IO, got/)
    end
  end

end
