require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))
require 'delegate'
require 'java' if RUBY_PLATFORM =~ /java/

module LibTest
  attach_function :ptr_ret_int32_t, [ :pointer, :int ], :int
  attach_function :ptr_from_address, [ FFI::Platform::ADDRESS_SIZE == 32 ? :uint : :ulong_long ], :pointer
  attach_function :ptr_set_pointer, [ :pointer, :int, :pointer ], :void
  attach_function :ptr_ret_pointer, [ :pointer, :int ], :pointer
end
describe "Pointer" do
  include FFI
  class ToPtrTest
    def initialize(ptr)
      @ptr = ptr
    end
    def to_ptr
      @ptr
    end
  end
  it "Any object implementing #to_ptr can be passed as a :pointer parameter" do
    memory = FFI::MemoryPointer.new :long_long
    magic = 0x12345678
    memory.put_int32(0, magic)
    tp = ToPtrTest.new(memory)
    LibTest.ptr_ret_int32_t(tp, 0).should == magic
  end
  class PointerDelegate < DelegateClass(FFI::Pointer)
    def initialize(ptr)
      @ptr = ptr
    end
    def to_ptr
      @ptr
    end
  end
  it "A DelegateClass(Pointer) can be passed as a :pointer parameter" do
    memory = FFI::MemoryPointer.new :long_long
    magic = 0x12345678
    memory.put_int32(0, magic)
    ptr = PointerDelegate.new(memory)
    LibTest.ptr_ret_int32_t(ptr, 0).should == magic
  end
  it "Fixnum cannot be used as a Pointer argument" do
    lambda { LibTest.ptr_ret_int32(0, 0) }.should raise_error
  end
  it "Bignum cannot be used as a Pointer argument" do
    lambda { LibTest.ptr_ret_int32(0xfee1deadbeefcafebabe, 0) }.should raise_error
  end

  describe "pointer type methods" do

    describe "#read_pointer" do
      memory = FFI::MemoryPointer.new :pointer
      LibTest.ptr_set_pointer(memory, 0, LibTest.ptr_from_address(0xdeadbeef))
      memory.read_pointer.address.should == 0xdeadbeef
    end

    describe "#write_pointer" do
      memory = FFI::MemoryPointer.new :pointer
      memory.write_pointer(LibTest.ptr_from_address(0xdeadbeef))
      LibTest.ptr_ret_pointer(memory, 0).address.should == 0xdeadbeef
    end

    describe "#read_array_of_pointer" do
      values = [0x12345678, 0xfeedf00d, 0xdeadbeef]
      memory = FFI::MemoryPointer.new :pointer, values.size
      values.each_with_index do |address, j|
        LibTest.ptr_set_pointer(memory, j * FFI.type_size(:pointer), LibTest.ptr_from_address(address))
      end
      array = memory.read_array_of_pointer(values.size)
      values.each_with_index do |address, j|
        array[j].address.should == address
      end
    end

    describe "#write_array_of_pointer" do
      values = [0x12345678, 0xfeedf00d, 0xdeadbeef]
      memory = FFI::MemoryPointer.new :pointer, values.size
      memory.write_array_of_pointer(values.map { |address| LibTest.ptr_from_address(address) })
      array = []
      values.each_with_index do |address, j|
        array << LibTest.ptr_ret_pointer(memory, j * FFI.type_size(:pointer))
      end
      values.each_with_index do |address, j|
        array[j].address.should == address
      end
    end
    
  end

  describe 'NULL' do
    it 'should be obtained using Pointer::NULL constant' do
      null_ptr = FFI::Pointer::NULL
      null_ptr.null?.should be_true
    end
    it 'should be obtained passing address 0 to constructor' do
      FFI::Pointer.new(0).null?.should be_true
    end
    it 'should raise an error when attempting read/write operations on it' do
      null_ptr = FFI::Pointer::NULL
      lambda { null_ptr.read_int }.should raise_error(FFI::NullPointerError)
      lambda { null_ptr.write_int(0xff1) }.should raise_error(FFI::NullPointerError)
    end
  end

end

describe "AutoPointer" do
  loop_count = 30
  wiggle_room = 5 # GC rarely cleans up all objects. we can get most of them, and that's enough to determine if the basic functionality is working.
  magic = 0x12345678

  class AutoPointerTestHelper
    @@count = 0
    def self.release
      @@count += 1 if @@count > 0
    end
    def self.reset
      @@count = 0
    end
    def self.gc_everything(count)
      loop = 5
      while @@count < count && loop > 0
        loop -= 1
        if RUBY_PLATFORM =~ /java/
          java.lang.System.gc
        else
          GC.start
        end
        sleep 0.05 unless @@count == count
      end
      @@count = 0
    end
    def self.finalizer
      self.method(:release).to_proc
    end
  end
  class AutoPointerSubclass < FFI::AutoPointer
    def self.release(ptr); end
  end
  it "cleanup via default release method" do
    AutoPointerSubclass.should_receive(:release).at_least(loop_count-wiggle_room).times
    AutoPointerTestHelper.reset
    loop_count.times do
      # note that if we called
      # AutoPointerTestHelper.method(:release).to_proc inline, we'd
      # have a reference to the pointer and it would never get GC'd.
      ap = AutoPointerSubclass.new(LibTest.ptr_from_address(magic))
    end
    AutoPointerTestHelper.gc_everything loop_count
  end

  it "cleanup when passed a proc" do
    #  NOTE: passing a proc is touchy, because it's so easy to create a memory leak.
    #
    #  specifically, if we made an inline call to
    #
    #      AutoPointerTestHelper.method(:release).to_proc
    #
    #  we'd have a reference to the pointer and it would
    #  never get GC'd.
    AutoPointerTestHelper.should_receive(:release).at_least(loop_count-wiggle_room).times
    AutoPointerTestHelper.reset
    loop_count.times do
      ap = FFI::AutoPointer.new(LibTest.ptr_from_address(magic),
                                AutoPointerTestHelper.finalizer)
    end
    AutoPointerTestHelper.gc_everything loop_count
  end

  it "cleanup when passed a method" do
    AutoPointerTestHelper.should_receive(:release).at_least(loop_count-wiggle_room).times
    AutoPointerTestHelper.reset
    loop_count.times do
      ap = FFI::AutoPointer.new(LibTest.ptr_from_address(magic),
                                AutoPointerTestHelper.method(:release))
    end
    AutoPointerTestHelper.gc_everything loop_count
  end
end
describe "AutoPointer#new" do
  class AutoPointerSubclass < FFI::AutoPointer
    def self.release(ptr); end
  end
  it "MemoryPointer argument raises TypeError" do
    lambda { FFI::AutoPointer.new(FFI::MemoryPointer.new(:int))}.should raise_error(::TypeError)
  end
  it "AutoPointer argument raises TypeError" do
    lambda { AutoPointerSubclass.new(AutoPointerSubclass.new(LibTest.ptr_from_address(0))) }.should raise_error(::TypeError)
  end
  it "Buffer argument raises TypeError" do
    lambda { FFI::AutoPointer.new(FFI::Buffer.new(:int))}.should raise_error(::TypeError)
  end

end
