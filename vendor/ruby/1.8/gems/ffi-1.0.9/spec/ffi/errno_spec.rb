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
describe "FFI.errno" do
  module LibTest
    extend FFI::Library
    ffi_lib TestLibrary::PATH
    attach_function :setLastError, [ :int ], :void
  end
  it "FFI.errno contains errno from last function" do
    LibTest.setLastError(0)
    LibTest.setLastError(0x12345678)
    FFI.errno.should == 0x12345678
  end
end