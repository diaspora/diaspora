require 'rubygems'
require 'rbconfig'
require 'spec'

if RUBY_PLATFORM =~/java/
  libdir = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "lib"))
  $:.reject! { |p| p == libdir }
else
  $:.unshift File.join(File.dirname(__FILE__), "..", "..", "lib"),
    File.join(File.dirname(__FILE__), "..", "..", "build", "#{Config::CONFIG['host_cpu''arch']}", "ffi_c", RUBY_VERSION)
end
puts "loadpath=#{$:.join(':')}"
require "ffi"

module TestLibrary
  PATH = "build/libtest.#{FFI::Platform::LIBSUFFIX}"
end
module LibTest
  extend FFI::Library
  ffi_lib TestLibrary::PATH
end
