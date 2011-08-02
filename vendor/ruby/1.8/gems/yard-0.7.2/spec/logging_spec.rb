require File.join(File.dirname(__FILE__), "spec_helper")

describe YARD::Logger do
  describe '#show_backtraces' do
    it "should be true if debug level is on" do
      log.show_backtraces = true
      log.enter_level(Logger::DEBUG) do
        log.show_backtraces = false
        log.show_backtraces.should == true
      end
      log.show_backtraces.should == false
    end
  end
end
