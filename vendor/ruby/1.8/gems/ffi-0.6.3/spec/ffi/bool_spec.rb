require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))
describe "Function with primitive boolean arguments and return values" do
  module LibTest
    extend FFI::Library
    ffi_lib TestLibrary::PATH
    attach_function :bool_return_true, [ ], :bool
    attach_function :bool_return_false, [ ], :bool
    attach_function :bool_return_val, [ :bool ], :bool
    attach_function :bool_reverse_val, [ :bool ], :bool
  end
  it "bools" do
    LibTest.bool_return_true.should == true
    LibTest.bool_return_false.should == false

    LibTest.bool_return_val(true).should == true
    LibTest.bool_return_val(false).should == false

    LibTest.bool_reverse_val(true).should == false
    LibTest.bool_reverse_val(false).should == true
  end
  it "raise error on invalid types" do
    lambda { LibTest.bool_return_val(nil) }.should raise_error(::TypeError)
  end
end
