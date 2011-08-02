#
# Copyright (C) 2008, 2009 Wayne Meissner
# All rights reserved.
#
# This file is part of ruby-ffi.
#
# All rights reserved.
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

require 'rbconfig'
module FFI
  class PlatformError < LoadError; end

  module Platform
    OS = case Config::CONFIG['host_os'].downcase
    when /linux/
      "linux"
    when /darwin/
      "darwin"
    when /freebsd/
      "freebsd"
    when /openbsd/
      "openbsd"
    when /sunos|solaris/
      "solaris"
    when /win|mingw/
      "windows"
    else
      Config::CONFIG['host_os'].downcase
    end

    ARCH = case CPU.downcase
    when /amd64|x86_64/
      "x86_64"
    when /i?86|x86|i86pc/
      "i386"
    when /ppc|powerpc/
      "powerpc"
    else
      Config::CONFIG['host_cpu']
    end

    private
    def self.is_os(os)
      OS == os
    end
    
    NAME = "#{ARCH}-#{OS}"
    IS_LINUX = is_os("linux")
    IS_MAC = is_os("darwin")
    IS_FREEBSD = is_os("freebsd")
    IS_OPENBSD = is_os("openbsd")
    IS_WINDOWS = is_os("windows")
    IS_BSD = IS_MAC || IS_FREEBSD || IS_OPENBSD
    CONF_DIR = File.join(File.dirname(__FILE__), 'platform', ARCH.to_s + "-" + OS.to_s)
    public

    

    LIBPREFIX = IS_WINDOWS ? '' : 'lib'

    LIBSUFFIX = case OS
    when /darwin/
      'dylib'
    when /linux|bsd|solaris/
      'so'
    when /windows/
      'dll'
    else
      # Punt and just assume a sane unix (i.e. anything but AIX)
      'so'
    end

    LIBC = if IS_WINDOWS
      "msvcrt.dll"
    elsif IS_LINUX
      "libc.so.6"
    else
      "#{LIBPREFIX}c.#{LIBSUFFIX}"
    end

    def self.bsd?
      IS_BSD
    end

    def self.windows?
      IS_WINDOWS
    end

    def self.mac?
      IS_MAC
    end

    def self.unix?
      !IS_WINDOWS
    end
  end
end

