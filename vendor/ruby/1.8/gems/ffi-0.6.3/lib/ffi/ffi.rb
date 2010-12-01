#
# Copyright (C) 2008 JRuby project
# Copyright (c) 2007, 2008 Evan Phoenix
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

module FFI
  #  Specialised error classes
  class NativeError < LoadError; end
  
  class SignatureError < NativeError; end
  
  class NotFoundError < NativeError
    def initialize(function, *libraries)
      super("Function '#{function}' not found in [#{libraries[0].nil? ? 'current process' : libraries.join(", ")}]")
    end
  end
end

require 'ffi/platform'
require 'ffi/types'
require 'ffi/library'
require 'ffi/errno'
require 'ffi/memorypointer'
require 'ffi/struct'
require 'ffi/union'
require 'ffi/managedstruct'
require 'ffi/callback'
require 'ffi/io'
require 'ffi/autopointer'
require 'ffi/variadic'
require 'ffi/enum'

module FFI
  
  def self.map_library_name(lib)
    # Mangle the library name to reflect the native library naming conventions
    lib = lib.to_s unless lib.kind_of?(String)
    lib = Platform::LIBC if Platform::IS_LINUX && lib == 'c'
    if lib && File.basename(lib) == lib
      ext = ".#{Platform::LIBSUFFIX}"
      lib = Platform::LIBPREFIX + lib unless lib =~ /^#{Platform::LIBPREFIX}/
      lib += ext unless lib =~ /#{ext}/
    end
    lib
  end


  def self.create_invoker(lib, name, args, ret_type, options = { :convention => :default })
    # Current artificial limitation based on JRuby::FFI limit
    raise SignatureError, 'FFI functions may take max 32 arguments!' if args.size > 32

    # Open the library if needed
    library = if lib.kind_of?(DynamicLibrary)
      lib
    elsif lib.kind_of?(String)
      # Allow FFI.create_invoker to be  called with a library name
      DynamicLibrary.open(FFI.map_library_name(lib), DynamicLibrary::RTLD_LAZY)
    elsif lib.nil?
      FFI::Library::DEFAULT
    else
      raise LoadError, "Invalid library '#{lib}'"
    end
    function = library.find_function(name)
    raise NotFoundError.new(name, library.name) unless function

    args = args.map {|e| find_type(e) }
    invoker = if args.length > 0 && args[args.length - 1] == FFI::NativeType::VARARGS
      FFI::VariadicInvoker.new(function, args, find_type(ret_type), options)
    else
      FFI::Function.new(find_type(ret_type), args, function, options)
    end
    raise NotFoundError.new(name, library.name) unless invoker

    return invoker
  end
end
