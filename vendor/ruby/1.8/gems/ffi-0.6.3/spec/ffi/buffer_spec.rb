require "rubygems"
require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))
include FFI
LongSize = FFI::Platform::LONG_SIZE / 8

describe "Buffer#total" do
  [1,2,3].each do |i|
    { :char => 1, :uchar => 1, :short => 2, :ushort => 2, :int => 4, 
      :uint => 4, :long => LongSize, :ulong => LongSize, 
      :long_long => 8, :ulong_long => 8, :float => 4, :double => 8
    }.each_pair do |t, s|
      it "Buffer.alloc_in(#{t}, #{i}).total == #{i * s}" do
        Buffer.alloc_in(t, i).total.should == i * s
      end
      it "Buffer.alloc_out(#{t}, #{i}).total == #{i * s}" do
        Buffer.alloc_out(t, i).total.should == i * s
      end
      it "Buffer.alloc_inout(#{t}, #{i}).total == #{i * s}" do
        Buffer.alloc_inout(t, i).total.should == i * s
      end
    end
  end
end

describe "Buffer#put_char" do
  bufsize = 4
  (0..127).each do |i|
    (0..bufsize-1).each do |offset|
      it "put_char(#{offset}, #{i}).get_char(#{offset}) == #{i}" do
        Buffer.alloc_in(bufsize).put_char(offset, i).get_char(offset).should == i
      end
    end
  end
end
describe "Buffer#put_uchar" do
  bufsize = 4
  (0..255).each do |i|
    (0..bufsize-1).each do |offset|
      it "Buffer.put_uchar(#{offset}, #{i}).get_uchar(#{offset}) == #{i}" do
        Buffer.alloc_in(bufsize).put_uchar(offset, i).get_uchar(offset).should == i
      end
    end
  end 
end
describe "Buffer#put_short" do
  bufsize = 4
  [0, 1, 128, 32767].each do |i|
    (0..bufsize-2).each do |offset|
      it "put_short(#{offset}, #{i}).get_short(#{offset}) == #{i}" do
        Buffer.alloc_in(bufsize).put_short(offset, i).get_short(offset).should == i
      end
    end
  end
end
describe "Buffer#put_ushort" do
  bufsize = 4
  [ 0, 1, 128, 32767, 65535, 0xfee1, 0xdead, 0xbeef, 0xcafe ].each do |i|
    (0..bufsize-2).each do |offset|
      it "put_ushort(#{offset}, #{i}).get_ushort(#{offset}) == #{i}" do
        Buffer.alloc_in(bufsize).put_ushort(offset, i).get_ushort(offset).should == i
      end
    end
  end
end
describe "Buffer#put_int" do
  bufsize = 8
  [0, 1, 128, 32767, 0x7ffffff ].each do |i|
    (0..bufsize-4).each do |offset|
      it "put_int(#{offset}, #{i}).get_int(#{offset}) == #{i}" do
        Buffer.alloc_in(bufsize).put_int(offset, i).get_int(offset).should == i
      end
    end
  end
end
describe "Buffer#put_uint" do
  bufsize = 8
  [ 0, 1, 128, 32767, 65535, 0xfee1dead, 0xcafebabe, 0xffffffff ].each do |i|
    (0..bufsize-4).each do |offset|
      it "put_uint(#{offset}, #{i}).get_uint(#{offset}) == #{i}" do
        Buffer.alloc_in(bufsize).put_uint(offset, i).get_uint(offset).should == i
      end
    end
  end
end
describe "Buffer#put_long" do
  bufsize = 16
  [0, 1, 128, 32767, 0x7ffffff ].each do |i|
    (0..bufsize-LongSize).each do |offset|
      it "put_long(#{offset}, #{i}).get_long(#{offset}) == #{i}" do
        Buffer.alloc_in(bufsize).put_long(offset, i).get_long(offset).should == i
      end
    end
  end
end
describe "Buffer#put_ulong" do
  bufsize = 16
  [ 0, 1, 128, 32767, 65535, 0xfee1dead, 0xcafebabe, 0xffffffff ].each do |i|
    (0..bufsize-LongSize).each do |offset|
      it "put_ulong(#{offset}, #{i}).get_ulong(#{offset}) == #{i}" do
        Buffer.alloc_in(bufsize).put_ulong(offset, i).get_ulong(offset).should == i
      end
    end
  end
end
describe "Buffer#put_long_long" do
  bufsize = 16
  [0, 1, 128, 32767, 0x7ffffffffffffff ].each do |i|
    (0..bufsize-8).each do |offset|
      it "put_long_long(#{offset}, #{i}).get_long_long(#{offset}) == #{i}" do
        Buffer.alloc_in(bufsize).put_long_long(offset, i).get_long_long(offset).should == i
      end
    end
  end
end
describe "Buffer#put_ulong_long" do
  bufsize = 16
  [ 0, 1, 128, 32767, 65535, 0xdeadcafebabe, 0x7fffffffffffffff ].each do |i|
    (0..bufsize-8).each do |offset|
      it "put_ulong_long(#{offset}, #{i}).get_ulong_long(#{offset}) == #{i}" do
        Buffer.alloc_in(bufsize).put_ulong_long(offset, i).get_ulong_long(offset).should == i
      end
    end
  end
end
describe "Reading/Writing binary strings" do
  it "Buffer#put_bytes" do
    str = "hello\0world"
    buf = FFI::Buffer.new 1024
    buf.put_bytes(0, str);
    s2 = buf.get_bytes(0, 11);
    s2.should == str
  end
  it "Buffer#put_bytes with index and length" do
    str = "hello\0world"
    buf = FFI::Buffer.new 1024
    buf.put_bytes(0, str, 5, 6);
    s2 = buf.get_bytes(0, 6);
    s2.should == str[5..-1]
  end
  it "Buffer#put_bytes with only index" do
    str = "hello\0world"
    buf = FFI::Buffer.new 1024
    buf.put_bytes(0, str, 5);
    s2 = buf.get_bytes(0, 6);
    s2.should == str[5..-1]
  end
  it "Buffer#put_bytes with index > str.length" do
    str = "hello\0world"
    buf = FFI::Buffer.new 1024
    lambda { buf.put_bytes(0, str, 12); }.should raise_error
  end
  it "Buffer#put_bytes with length > str.length" do
    str = "hello\0world"
    buf = FFI::Buffer.new 1024
    lambda { buf.put_bytes(0, str, 0, 12); }.should raise_error
  end
   it "Buffer#put_bytes with negative index" do
    str = "hello\0world"
    buf = FFI::Buffer.new 1024
    lambda { buf.put_bytes(0, str, -1, 12); }.should raise_error
  end
end
describe "Reading/Writing ascii strings" do
  it "Buffer#put_string with string containing zero byte" do
    str = "hello\0world"
    buf = FFI::Buffer.new 1024
    buf.put_string(0, str);
    s2 = buf.get_bytes(0, 11);
    s2.should == str
  end
  it "Buffer#get_string with string containing zero byte" do
    str = "hello\0world"
    buf = FFI::Buffer.new 1024
    buf.put_bytes(0, str);
    s2 = buf.get_string(0, 11);
    s2.should == "hello"
  end
  it "Buffer#put_string without length should NUL terminate" do
    str = "hello"
    buf = FFI::Buffer.new 1024
    buf.put_string(0, str);
    s2 = buf.get_bytes(0, 6);
    s2.should == "hello\0"
  end
end
describe "Buffer#put_pointer" do
  it "put_pointer(0, p).get_pointer(0) == p" do
    p = MemoryPointer.new :ulong_long
    p.put_uint(0, 0xdeadbeef)
    buf = Buffer.alloc_inout 8
    p2 = buf.put_pointer(0, p).get_pointer(0)
    p2.should_not be_nil
    p2.should == p
    p2.get_uint(0).should == 0xdeadbeef
  end
end
describe "Buffer#size" do
  it "should return size" do
    buf = FFI::Buffer.new 14
    buf.size.should == 14
  end
end