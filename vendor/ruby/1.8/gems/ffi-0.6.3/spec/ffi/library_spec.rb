require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))
describe "Library" do

  unless Config::CONFIG['target_os'] =~ /mswin|mingw/
    it "attach_function with no library specified" do
      lambda {
        Module.new do |m|
          m.extend FFI::Library
          attach_function :getpid, [ ], :uint
        end
      }.should raise_error
    end
    it "attach_function :getpid from this process" do
      lambda {
        Module.new do |m|
          m.extend FFI::Library
          ffi_lib FFI::Library::CURRENT_PROCESS
          attach_function :getpid, [ ], :uint
        end.getpid.should == Process.pid
      }.should_not raise_error
    end
    it "attach_function :getpid from [ 'c', 'libc.so.6'] " do
      lambda {
        Module.new do |m|
          m.extend FFI::Library
          ffi_lib [ 'c', 'libc.so.6' ]
          attach_function :getpid, [ ], :uint
        end.getpid.should == Process.pid
      }.should_not raise_error
    end
    it "attach_function :getpid from [ 'libc.so.6', 'c' ] " do
      lambda {
        Module.new do |m|
          m.extend FFI::Library
          ffi_lib [ 'libc.so.6', 'c' ]
          attach_function :getpid, [ ], :uint
        end.getpid.should == Process.pid
      }.should_not raise_error
    end
    it "attach_function :getpid from [ 'libfubar.so.0xdeadbeef', nil, 'c' ] " do
      lambda {
        Module.new do |m|
          m.extend FFI::Library
          ffi_lib [ 'libfubar.so.0xdeadbeef', nil, 'c' ]
          attach_function :getpid, [ ], :uint
        end.getpid.should == Process.pid
      }.should_not raise_error
    end
    it "attach_function :getpid from [ 'libfubar.so.0xdeadbeef' ] " do
      lambda {
        Module.new do |m|
          m.extend FFI::Library
          ffi_lib 'libfubar.so.0xdeadbeef'
          attach_function :getpid, [ ], :uint
        end.getpid.should == Process.pid
      }.should raise_error(LoadError)
    end
  end

  def gvar_lib(name, type)
    Module.new do |m|
      m.extend FFI::Library
      ffi_lib TestLibrary::PATH
      attach_variable :gvar, "gvar_#{name}", type
      attach_function :get, "gvar_#{name}_get", [], type
      attach_function :set, "gvar_#{name}_set", [ type ], :void
    end
  end
  def gvar_test(name, type, val)
    lib = gvar_lib(name, type)
    lib.set(val)
    lib.gvar.should == val
    lib.set(0)
    lib.gvar = val
    lib.get.should == val
  end
  [ 0, 127, -128, -1 ].each do |i|
    it ":char variable" do
      gvar_test("s8", :char, i)
    end
  end
  [ 0, 0x7f, 0x80, 0xff ].each do |i|
    it ":uchar variable" do
      gvar_test("u8", :uchar, i)
    end
  end
  [ 0, 0x7fff, -0x8000, -1 ].each do |i|
    it ":short variable" do
      gvar_test("s16", :short, i)
    end
  end
  [ 0, 0x7fff, 0x8000, 0xffff ].each do |i|
    it ":ushort variable" do
      gvar_test("u16", :ushort, i)
    end
  end
  [ 0, 0x7fffffff, -0x80000000, -1 ].each do |i|
    it ":int variable" do
      gvar_test("s32", :int, i)
    end
  end
  [ 0, 0x7fffffff, 0x80000000, 0xffffffff ].each do |i|
    it ":uint variable" do
      gvar_test("u32", :uint, i)
    end
  end
  [ 0, 0x7fffffffffffffff, -0x8000000000000000, -1 ].each do |i|
    it ":long_long variable" do
      gvar_test("s64", :long_long, i)
    end
  end
  [ 0, 0x7fffffffffffffff, 0x8000000000000000, 0xffffffffffffffff ].each do |i|
    it ":ulong_long variable" do
      gvar_test("u64", :ulong_long, i)
    end
  end
  if FFI::Platform::LONG_SIZE == 32
    [ 0, 0x7fffffff, -0x80000000, -1 ].each do |i|
      it ":long variable" do
        gvar_test("long", :long, i)
      end
    end
    [ 0, 0x7fffffff, 0x80000000, 0xffffffff ].each do |i|
      it ":ulong variable" do
        gvar_test("ulong", :ulong, i)
      end
    end
  else
    [ 0, 0x7fffffffffffffff, -0x8000000000000000, -1 ].each do |i|
      it ":long variable" do
        gvar_test("long", :long, i)
      end
    end
    [ 0, 0x7fffffffffffffff, 0x8000000000000000, 0xffffffffffffffff ].each do |i|
      it ":ulong variable" do
        gvar_test("ulong", :ulong, i)
      end
    end
  end
  it "Pointer variable" do
    lib = gvar_lib("pointer", :pointer)
    val = FFI::MemoryPointer.new :long
    lib.set(val)
    lib.gvar.should == val
    lib.set(nil)
    lib.gvar = val
    lib.get.should == val
  end

  [ 0, 0x7fffffff, -0x80000000, -1 ].each do |i|
    it "structure" do
      class GlobalStruct < FFI::Struct
        layout :data, :long
      end

      lib = Module.new do |m|
        m.extend FFI::Library
        ffi_lib TestLibrary::PATH
        attach_variable :gvar, "gvar_gstruct", GlobalStruct
        attach_function :get, "gvar_gstruct_get", [], GlobalStruct
        attach_function :set, "gvar_gstruct_set", [ GlobalStruct ], :void
      end

      val = GlobalStruct.new
      val[:data] = i
      lib.set(val)
      lib.gvar[:data].should == i
      val[:data] = 0
      lib.gvar[:data] = i
      val = GlobalStruct.new(lib.get)
      val[:data].should == i
    end
  end
end
