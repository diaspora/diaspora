#
# This file is part of ruby-ffi.
#
# This code is free software: you can redistribute it and/or modify it under
# the terms of the GNU Lesser General Public License version 3 only, as
# published by the Free Software Foundation.
#
# This code is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License
# version 3 for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# version 3 along with this work.  If not, see <http://www.gnu.org/licenses/>.
#

require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))
describe "String tests" do
  include FFI
  module StrLibTest
    extend FFI::Library
    ffi_lib TestLibrary::PATH
    attach_function :ptr_ret_pointer, [ :pointer, :int], :string
    attach_function :string_equals, [ :string, :string ], :int
    attach_function :string_dummy, [ :string ], :void
    attach_function :string_null, [ ], :string
  end
  it "MemoryPointer#get_string returns a tainted string" do
    mp = FFI::MemoryPointer.new 1024
    mp.put_string(0, "test\0")
    str = mp.get_string(0)
    str.tainted?.should == true
  end
  it "String returned by a method is tainted" do
    mp = FFI::MemoryPointer.new :pointer
    sp = FFI::MemoryPointer.new 1024
    sp.put_string(0, "test")
    mp.put_pointer(0, sp)
    str = StrLibTest.ptr_ret_pointer(mp, 0)
    str.should == "test"
    str.tainted?.should == true
  end
  it "Poison null byte raises error" do
    s = "123\0abc"
    lambda { StrLibTest.string_equals(s, s) }.should raise_error
  end
  it "Tainted String parameter should throw a SecurityError" do
    $SAFE = 1
    str = "test"
    str.taint
    begin
      LibTest.string_equals(str, str).should == false
    rescue SecurityError => e
    end
  end if false
  it "casts nil as NULL pointer" do
    StrLibTest.string_dummy(nil)
  end
  it "return nil for NULL char*" do
    StrLibTest.string_null.should == nil
  end
  it "reads an array of strings until encountering a NULL pointer" do
    strings = ["foo", "bar", "baz", "testing", "ffi"]
    ptrary = FFI::MemoryPointer.new(:pointer, 6)
    ary = strings.inject([]) do |a, str|
      f = FFI::MemoryPointer.new(1024)
      f.put_string(0, str)
      a << f
    end
    ary.insert(3, nil)
    ptrary.write_array_of_pointer(ary)
    ptrary.get_array_of_string(0).should == ["foo", "bar", "baz"]
  end
  it "reads an array of strings of the size specified, substituting nil when a pointer is NULL" do
    strings = ["foo", "bar", "baz", "testing", "ffi"]
    ptrary = FFI::MemoryPointer.new(:pointer, 6)
    ary = strings.inject([]) do |a, str|
      f = FFI::MemoryPointer.new(1024)
      f.put_string(0, str)
      a << f
    end
    ary.insert(2, nil)
    ptrary.write_array_of_pointer(ary)
    ptrary.get_array_of_string(0, 4).should == ["foo", "bar", nil, "baz"]
  end
  it "reads an array of strings, taking a memory offset parameter" do
    strings = ["foo", "bar", "baz", "testing", "ffi"]
    ptrary = FFI::MemoryPointer.new(:pointer, 5)
    ary = strings.inject([]) do |a, str|
      f = FFI::MemoryPointer.new(1024)
      f.put_string(0, str)
      a << f
    end
    ptrary.write_array_of_pointer(ary)
    ptrary.get_array_of_string(2 * FFI.type_size(:pointer), 3).should == ["baz", "testing", "ffi"]
  end
  it "raises an IndexError when trying to read an array of strings out of bounds" do
    strings = ["foo", "bar", "baz", "testing", "ffi"]
    ptrary = FFI::MemoryPointer.new(:pointer, 5)
    ary = strings.inject([]) do |a, str|
      f = FFI::MemoryPointer.new(1024)
      f.put_string(0, str)
      a << f
    end
    ptrary.write_array_of_pointer(ary)
    lambda { ptrary.get_array_of_string(0, 6) }.should raise_error
  end
  it "raises an IndexError when trying to read an array of strings using a negative offset" do
    strings = ["foo", "bar", "baz", "testing", "ffi"]
    ptrary = FFI::MemoryPointer.new(:pointer, 5)
    ary = strings.inject([]) do |a, str|
      f = FFI::MemoryPointer.new(1024)
      f.put_string(0, str)
      a << f
    end
    ptrary.write_array_of_pointer(ary)
    lambda { ptrary.get_array_of_string(-1) }.should raise_error
  end
end
