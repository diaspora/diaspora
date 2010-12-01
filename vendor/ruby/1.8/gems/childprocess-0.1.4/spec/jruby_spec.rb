require File.expand_path('../spec_helper', __FILE__)

if ChildProcess.jruby?
  describe ChildProcess::JRuby::IO do
    let(:io) { ChildProcess::JRuby::IO.new }

    it "raises an ArgumentError if given IO does not respond to :to_outputstream" do
      lambda { io.stdout = nil }.should raise_error(ArgumentError)
    end
  end

end