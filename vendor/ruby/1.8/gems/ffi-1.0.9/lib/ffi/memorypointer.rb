#
# Copyright (C) 2008, 2009 Wayne Meissner
# All rights reserved.
#
# All rights reserved.
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

require 'ffi/pointer'
module FFI
  class MemoryPointer
      
      def self.from_string(s)
        ptr = self.new(s.bytesize + 1, 1, false)
        ptr.put_string(0, s)
        ptr
      end

  end
end
