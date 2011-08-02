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

describe FFI::Struct, ' with an initialize function' do
  it "should call the initialize function" do
    class StructWithInitialize < FFI::Struct
      layout :string, :string
      attr_accessor :magic
      def initialize
        super
        self.magic = 42
      end
    end
    StructWithInitialize.new.magic.should == 42
  end
end

describe FFI::ManagedStruct, ' with an initialize function' do
  it "should call the initialize function" do
    class ManagedStructWithInitialize < FFI::ManagedStruct
      layout :string, :string
      attr_accessor :magic
      def initialize
        super FFI::MemoryPointer.new(:pointer).put_int(0, 0x1234).get_pointer(0)
        self.magic = 42
      end
      def self.release;end
    end
    ManagedStructWithInitialize.new.magic.should == 42
  end
end
