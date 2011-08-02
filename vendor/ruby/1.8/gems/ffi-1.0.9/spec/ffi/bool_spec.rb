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
describe "Function with primitive boolean arguments and return values" do
  module LibTest
    extend FFI::Library
    ffi_lib TestLibrary::PATH
    attach_function :bool_return_true, [ ], :bool
    attach_function :bool_return_false, [ ], :bool
    attach_function :bool_return_val, [ :bool ], :bool
    attach_function :bool_reverse_val, [ :bool ], :bool
  end
  it "bools" do
    LibTest.bool_return_true.should == true
    LibTest.bool_return_false.should == false

    LibTest.bool_return_val(true).should == true
    LibTest.bool_return_val(false).should == false

    LibTest.bool_reverse_val(true).should == false
    LibTest.bool_reverse_val(false).should == true
  end
  it "raise error on invalid types" do
    lambda { LibTest.bool_return_val(nil) }.should raise_error(::TypeError)
  end
end
