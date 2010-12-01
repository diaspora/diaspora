require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))
describe "Custom type definitions" do
  it "attach_function with custom typedef" do
    module CustomTypedef
      extend FFI::Library
      ffi_lib TestLibrary::PATH
      typedef :uint, :fubar_t
      attach_function :ret_u32, [ :fubar_t ], :fubar_t
    end
    CustomTypedef.ret_u32(0x12345678).should == 0x12345678
  end
  it "variadic invoker with custom typedef" do
    module VariadicCustomTypedef
      extend FFI::Library
      ffi_lib TestLibrary::PATH
      typedef :uint, :fubar_t
      attach_function :pack_varargs, [ :buffer_out, :string, :varargs ], :void
    end
    buf = FFI::Buffer.new :uint, 10
    VariadicCustomTypedef.pack_varargs(buf, "i", :fubar_t, 0x12345678)
    buf.get_int64(0).should == 0x12345678
  end
  it "Callback with custom typedef parameter" do
    module CallbackCustomTypedef
      extend FFI::Library
      ffi_lib TestLibrary::PATH
      typedef :uint, :fubar3_t
      callback :cbIrV, [ :fubar3_t ], :void
      attach_function :testCallbackU32rV, :testClosureIrV, [ :cbIrV, :fubar3_t ], :void
    end
    i = 0
    CallbackCustomTypedef.testCallbackU32rV(0xdeadbeef) { |v| i = v }
    i.should == 0xdeadbeef
  end
    module StructCustomTypedef
      extend FFI::Library
      ffi_lib TestLibrary::PATH
      typedef :uint, :fubar3_t
      class S < FFI::Struct
        layout :a, :fubar3_t
      end
    end
  it "Struct with custom typedef field" do
    s = StructCustomTypedef::S.new
    s[:a] = 0x12345678
    s.pointer.get_uint(0).should == 0x12345678
  end
end
