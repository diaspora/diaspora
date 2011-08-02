require File.expand_path('../spec_helper', __FILE__)

shared_examples_for "a platform that provides the child's pid" do
  it "knows the child's pid" do
    Tempfile.open("pid-spec") do |file|
      process = write_pid(file.path).start
      process.poll_for_exit(10)
      file.rewind

      process.pid.should == file.read.chomp.to_i
    end
  end
end
