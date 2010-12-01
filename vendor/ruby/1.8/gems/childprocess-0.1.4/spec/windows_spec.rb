require File.expand_path('../spec_helper', __FILE__)

if ChildProcess.windows?
  describe ChildProcess::Windows::IO do
    let(:io) { ChildProcess::Windows::IO.new }

    it "raises an ArgumentError if given IO does not respond to :fileno" do
      lambda { io.stdout = nil }.should raise_error(ArgumentError, /must have :fileno or :to_io/)
    end

    it "raises an ArgumentError if the #to_io does not return an IO " do
      fake_io = Object.new
      def fake_io.to_io() StringIO.new end

      lambda { io.stdout = fake_io }.should raise_error(ArgumentError, /must have :fileno or :to_io/)
    end
  end
end