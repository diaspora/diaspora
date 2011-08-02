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

describe "functions with custom parameter types" do
  before :each do

    Custom_enum = Class.new do
      extend FFI::DataConverter
      ToNativeMap= { :a => 1, :b => 2 }
      FromNativeMap = { 1 => :a, 2 => :b }

      def self.native_type
        @native_type_called = true
        FFI::Type::INT32
      end

      def self.to_native(val, ctx)
        @to_native_called = true
        ToNativeMap[val]
      end

      def self.from_native(val, ctx)
        @from_native_called = true
        FromNativeMap[val]
      end
      def self.native_type_called?; @native_type_called; end
      def self.from_native_called?; @from_native_called; end
      def self.to_native_called?; @to_native_called; end
    end

  end
end