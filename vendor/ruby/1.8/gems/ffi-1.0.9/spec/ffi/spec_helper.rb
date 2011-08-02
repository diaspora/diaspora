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
require 'rubygems'
require 'rbconfig'

if RUBY_PLATFORM =~/java/
  libdir = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "lib"))
  $:.reject! { |p| p == libdir }
else
  $:.unshift File.join(File.dirname(__FILE__), "..", "..", "lib"),
    File.join(File.dirname(__FILE__), "..", "..", "build", "#{Config::CONFIG['host_cpu''arch']}", "ffi_c", RUBY_VERSION)
end
# puts "loadpath=#{$:.join(':')}"
require "ffi"

module TestLibrary
  PATH = "build/libtest.#{FFI::Platform::LIBSUFFIX}"
end
module LibTest
  extend FFI::Library
  ffi_lib TestLibrary::PATH
end
