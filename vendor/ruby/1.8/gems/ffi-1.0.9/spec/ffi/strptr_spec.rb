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

describe "functions returning :strptr" do

  it "can attach function with :strptr return type" do
    lambda do
      m = Module.new do
        extend FFI::Library
        ffi_lib FFI::Library::LIBC
        if !FFI::Platform.windows?
          attach_function :strdup, [ :string ], :strptr
        else
          attach_function :_strdup, [ :string ], :strptr
        end
      end
    end.should_not raise_error
  end

  module StrPtr
    extend FFI::Library
    ffi_lib FFI::Library::LIBC
    attach_function :free, [ :pointer ], :void
    if !FFI::Platform.windows?
      attach_function :strdup, [ :string ], :strptr
    else
      attach_function :strdup, :_strdup, [ :string ], :strptr
    end
  end

  it "should return [ String, Pointer ]" do
    result = StrPtr.strdup("test")
    result[0].is_a?(String).should be_true
    result[1].is_a?(FFI::Pointer).should be_true
  end

  it "should return the correct value" do
    result = StrPtr.strdup("test")
    result[0].should == "test"
  end

  it "should return non-NULL pointer" do
    result = StrPtr.strdup("test")
    result[1].null?.should be_false
  end
end