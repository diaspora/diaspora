#
# Copyright (C) 2008, 2009 Wayne Meissner
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

module FFI
  module IO
    def self.for_fd(fd, mode = "r")
      ::IO.for_fd(fd, mode)
    end

    #
    # A version of IO#read that reads into a native buffer
    # 
    # This will be optimized at some future time to eliminate the double copy
    #
    def self.native_read(io, buf, len)
      tmp = io.read(len)
      return -1 unless tmp
      buf.put_bytes(0, tmp)
      tmp.length
    end

  end
end

