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

describe "async callback" do
  module LibTest
    extend FFI::Library
    ffi_lib TestLibrary::PATH
    AsyncIntCallback = callback [ :int ], :void

    @blocking = true
    attach_function :testAsyncCallback, [ AsyncIntCallback, :int ], :void
  end

  it ":int (0x7fffffff) argument" do
    v = 0xdeadbeef
    called = false
    cb = Proc.new {|i| v = i; called = true }
    LibTest.testAsyncCallback(cb, 0x7fffffff) 
    called.should be_true
    v.should == 0x7fffffff
  end
  
  it "called a second time" do
    v = 0xdeadbeef
    called = false
    cb = Proc.new {|i| v = i; called = true }
    LibTest.testAsyncCallback(cb, 0x7fffffff) 
    called.should be_true
    v.should == 0x7fffffff
  end
end
