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

describe "Pointer#dup" do 
  it "clone should be independent" do
    p1 = FFI::MemoryPointer.new(:char, 1024)
    p1.put_string(0, "test123");
    p2 = p1.dup
    p1.put_string(0, "deadbeef")
    
    p2.get_string(0).should == "test123"
  end
  
  it "sliced pointer can be cloned" do
    p1 = FFI::MemoryPointer.new(:char, 1024)
    p1.put_string(0, "test123");
    p2 = p1[1].dup
    
    # first char will be excised
    p2.get_string(0).should == "est123"
    p1.get_string(0).should == "test123"
  end
  
  it "sliced pointer when cloned is independent" do
    p1 = FFI::MemoryPointer.new(:char, 1024)
    p1.put_string(0, "test123");
    p2 = p1[1].dup
    
    p1.put_string(0, "deadbeef")
    # first char will be excised
    p2.get_string(0).should == "est123"
  end
end


describe "Struct#dup" do
  it "clone should be independent" do
    s = Class.new(FFI::Struct) do
      layout :i, :int
    end
    s1 = s.new
    s1[:i] = 0x12345
    s2 = s1.dup
    s1[:i] = 0x98765
    s2[:i].should == 0x12345
    s1[:i].should == 0x98765
  end
  
end