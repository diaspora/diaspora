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

describe "FFI" do

  describe ".map_library_name" do

    let(:prefix) { FFI::Platform::LIBPREFIX }
    let(:suffix) { FFI::Platform::LIBSUFFIX }
    
    it "should add platform library extension if not present" do
      FFI.map_library_name("#{prefix}dummy").should == "#{prefix}dummy.#{suffix}"
    end

    it "should add platform library extension even if lib suffix is present in name" do
      FFI.map_library_name("#{prefix}dummy_with_#{suffix}").should == "#{prefix}dummy_with_#{suffix}.#{suffix}"
    end

    it "should return Platform::LIBC when called with 'c'" do
      FFI.map_library_name('c').should == FFI::Library::LIBC
    end

  end

end
