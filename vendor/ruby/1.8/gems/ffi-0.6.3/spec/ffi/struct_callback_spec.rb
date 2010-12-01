require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))

describe FFI::Struct, ' with inline callback functions' do
  it 'should be able to define inline callback field' do
    module CallbackMember
      extend FFI::Library
      ffi_lib TestLibrary::PATH
      DUMMY_CB = callback :dummy_cb, [ :int ], :int
      class TestStruct < FFI::Struct
        layout \
          :add, callback([ :int, :int ], :int),
          :sub, callback([ :int, :int ], :int),
          :cb_with_cb_parameter, callback([ DUMMY_CB, :int ], :int)
      end
      attach_function :struct_call_add_cb, [TestStruct, :int, :int], :int
      attach_function :struct_call_sub_cb, [TestStruct, :int, :int], :int
    end
  end
  it 'should take methods as callbacks' do
    module CallbackMember
      extend FFI::Library
      ffi_lib TestLibrary::PATH
      class TestStruct < FFI::Struct
        layout \
          :add, callback([ :int, :int ], :int),
          :sub, callback([ :int, :int ], :int)
      end
      attach_function :struct_call_add_cb, [TestStruct, :int, :int], :int
      attach_function :struct_call_sub_cb, [TestStruct, :int, :int], :int
    end
    module StructCallbacks
      def self.add a, b
        a+b
      end
    end

    ts = CallbackMember::TestStruct.new
    ts[:add] = StructCallbacks.method(:add)

    CallbackMember.struct_call_add_cb(ts, 1, 2).should == 3
  end

  it 'should return callable object from []' do
    module CallbackMember
      extend FFI::Library
      ffi_lib TestLibrary::PATH
      class TestStruct < FFI::Struct
        layout \
          :add, callback([ :int, :int ], :int),
          :sub, callback([ :int, :int ], :int)
      end
      attach_function :struct_call_add_cb, [TestStruct, :int, :int], :int
      attach_function :struct_call_sub_cb, [TestStruct, :int, :int], :int
    end

    s = CallbackMember::TestStruct.new
    add = Proc.new { |a,b| a+b}
    s[:add] = add
    fn = s[:add]
    fn.respond_to?(:call).should be_true
    fn.call(1, 2).should == 3
  end
end

