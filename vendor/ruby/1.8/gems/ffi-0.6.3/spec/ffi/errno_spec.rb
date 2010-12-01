require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))
describe "FFI.errno" do
  module LibTest
    extend FFI::Library
    ffi_lib TestLibrary::PATH
    attach_function :setLastError, [ :int ], :void
  end
  it "FFI.errno contains errno from last function" do
    LibTest.setLastError(0)
    LibTest.setLastError(0x12345678)
    FFI.errno.should == 0x12345678
  end
end