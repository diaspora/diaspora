#
# Copyright (C) 2008, 2009 Wayne Meissner
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# * Neither the name of the Evan Phoenix nor the names of its contributors
#   may be used to endorse or promote products derived from this software
#   without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'rbconfig'
module FFI
  class PlatformError < FFI::NativeError; end

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
    CONF_DIR = File.dirname(__FILE__)
    public

    LIBC = if IS_WINDOWS
      "msvcrt"
    elsif IS_LINUX
      "libc.so.6"
    else
      "c"
    end

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

