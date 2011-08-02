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
describe "Function with variadic arguments" do
  module LibTest
    extend FFI::Library
    ffi_lib TestLibrary::PATH
    attach_function :pack_varargs, [ :buffer_out, :string, :varargs ], :void
  end
  [ 0, 127, -128, -1 ].each do |i|
    it "call variadic with (:char (#{i})) argument" do
      buf = FFI::Buffer.new :long_long
      LibTest.pack_varargs(buf, "c", :char, i)
      buf.get_int64(0).should == i
    end
  end
  [ 0, 0x7f, 0x80, 0xff ].each do |i|
    it "call variadic with (:uchar (#{i})) argument" do
      buf = FFI::Buffer.new :long_long
      LibTest.pack_varargs(buf, "C", :uchar, i)
      buf.get_int64(0).should == i
    end
  end
  [ 0, 1.234567, 9.87654321 ].each do |v|
    it "call variadic with (:float (#{v})) argument" do
      buf = FFI::Buffer.new :long_long
      LibTest.pack_varargs(buf, "f", :float, v.to_f)
      buf.get_float64(0).should == v
    end
  end
  [ 0, 1.234567, 9.87654321 ].each do |v|
    it "call variadic with (:double (#{v})) argument" do
      buf = FFI::Buffer.new :long_long
      LibTest.pack_varargs(buf, "f", :double, v.to_f)
      buf.get_float64(0).should == v
    end
  end
  module Varargs
    PACK_VALUES = {
      'c' => [ 0x12  ],
      'C' => [ 0x34  ],
      's' => [ 0x5678 ],
      'S' => [ 0x9abc ],
      'i' => [ 0x7654321f ],
      'I' => [ 0xfee1babe ],
      'l' => [ 0x1f2e3d4c ],
      'L' => [ 0xf7e8d9ca ],
      'j' => [ 0x1eafdeadbeefa1b2 ],
      'f' => [ 1.23456789 ],
      'd' => [ 9.87654321 ]
    }
    TYPE_MAP = {
      'c' => :char, 'C' => :uchar, 's' => :short, 'S' => :ushort,
      'i' => :int, 'I' => :uint, 'j' => :long_long, 'J' => :ulong_long,
      'l' => :long, 'L' => :ulong, 'f' => :float, 'd' => :double
    }
    def self.verify(p, off, v)
      if v.kind_of?(Float)
        p.get_float64(off).should == v
      else
        p.get_int64(off).should == v
      end
    end
  end
  Varargs::PACK_VALUES.keys.each do |t1|
    Varargs::PACK_VALUES.keys.each do |t2|
      Varargs::PACK_VALUES.keys.each do |t3|
        Varargs::PACK_VALUES[t1].each do |v1|
          Varargs::PACK_VALUES[t2].each do |v2|
            Varargs::PACK_VALUES[t3].each do |v3|
              fmt = "#{t1}#{t2}#{t3}"
              params = [ Varargs::TYPE_MAP[t1], v1, Varargs::TYPE_MAP[t2], v2, Varargs::TYPE_MAP[t3], v3 ]
              it "call(#{fmt}, #{params.join(',')})" do
                buf = FFI::Buffer.new :long_long, 3
                LibTest.pack_varargs(buf, fmt, *params)
                Varargs.verify(buf, 0, v1)
                Varargs.verify(buf, 8, v2)
                Varargs.verify(buf, 16, v3)
              end
            end
          end
        end
      end
    end
  end
end