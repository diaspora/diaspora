#
# Copyright (C) 2008, 2009 Wayne Meissner
# Copyright (C) 2009 Luc Heinrich
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
#  TypeDefs = Hash.new
  def self.add_typedef(current, add)
    if current.kind_of?(FFI::Type)
      code = current
    else
      code = TypeDefs[current]
      raise TypeError, "Unable to resolve type '#{current}'" unless code
    end

    TypeDefs[add] = code
  end
  def self.find_type(name, type_map = nil)
    type_map = TypeDefs if type_map.nil?
    code = type_map[name]
    code = name if !code && name.kind_of?(FFI::Type)
    raise TypeError, "Unable to resolve type '#{name}'" unless code
    return code
  end

  # Converts a char
  add_typedef(NativeType::INT8, :char)

  # Converts an unsigned char
  add_typedef(NativeType::UINT8, :uchar)

  # Converts an 8 bit int
  add_typedef(NativeType::INT8, :int8)

  # Converts an unsigned char
  add_typedef(NativeType::UINT8, :uint8)

  # Converts a short
  add_typedef(NativeType::INT16, :short)

  # Converts an unsigned short
  add_typedef(NativeType::UINT16, :ushort)

  # Converts a 16bit int
  add_typedef(NativeType::INT16, :int16)

  # Converts an unsigned 16 bit int
  add_typedef(NativeType::UINT16, :uint16)

  # Converts an int
  add_typedef(NativeType::INT32, :int)

  # Converts an unsigned int
  add_typedef(NativeType::UINT32, :uint)

  # Converts a 32 bit int
  add_typedef(NativeType::INT32, :int32)

  # Converts an unsigned 16 bit int
  add_typedef(NativeType::UINT32, :uint32)

  # Converts a long
  add_typedef(NativeType::LONG, :long)

  # Converts an unsigned long
  add_typedef(NativeType::ULONG, :ulong)

  # Converts a 64 bit int
  add_typedef(NativeType::INT64, :int64)

  # Converts an unsigned 64 bit int
  add_typedef(NativeType::UINT64, :uint64)

  # Converts a long long
  add_typedef(NativeType::INT64, :long_long)

  # Converts an unsigned long long
  add_typedef(NativeType::UINT64, :ulong_long)

  # Converts a float
  add_typedef(NativeType::FLOAT32, :float)

  # Converts a double
  add_typedef(NativeType::FLOAT64, :double)

  # Converts a pointer to opaque data
  add_typedef(NativeType::POINTER, :pointer)

  # For when a function has no return value
  add_typedef(NativeType::VOID, :void)

  # Converts NUL-terminated C strings
  add_typedef(NativeType::STRING, :string)

  # Converts FFI::Buffer objects
  add_typedef(NativeType::BUFFER_IN, :buffer_in)
  add_typedef(NativeType::BUFFER_OUT, :buffer_out)
  add_typedef(NativeType::BUFFER_INOUT, :buffer_inout)

  add_typedef(NativeType::VARARGS, :varargs)
  
  add_typedef(NativeType::ENUM, :enum)
  add_typedef(NativeType::BOOL, :bool)

  # Use for a C struct with a char [] embedded inside.
  add_typedef(NativeType::CHAR_ARRAY, :char_array)

  TypeSizes = {
    1 => :char,
    2 => :short,
    4 => :int,
    8 => :long_long,
  }
  SizeTypes.merge!({
    NativeType::INT8 => 1,
    NativeType::UINT8 => 1,
    NativeType::INT16 => 2,
    NativeType::UINT16 => 2,
    NativeType::INT32 => 4,
    NativeType::UINT32 => 4,
    NativeType::INT64 => 8,
    NativeType::UINT64 => 8,
    NativeType::FLOAT32 => 4,
    NativeType::FLOAT64 => 8,
    NativeType::LONG => FFI::Platform::LONG_SIZE / 8,
    NativeType::ULONG => FFI::Platform::LONG_SIZE / 8,
    NativeType::POINTER => FFI::Platform::ADDRESS_SIZE / 8,
  })

  def self.size_to_type(size)
    if sz = TypeSizes[size]
      return sz
    end

    # Be like C, use int as the default type size.
    return :int
  end
  def self.type_size(type)
    if sz = SizeTypes[find_type(type)]
      return sz
    end
    raise ArgumentError, "Unknown native type"
  end

  # Load all the platform dependent types
  begin
    File.open(File.join(FFI::Platform::CONF_DIR, 'types.conf'), "r") do |f|
      prefix = "rbx.platform.typedef."
      f.each_line { |line|
        if line.index(prefix) == 0
          new_type, orig_type = line.chomp.slice(prefix.length..-1).split(/\s*=\s*/)
          add_typedef(orig_type.to_sym, new_type.to_sym)
        end
      }
    end
  rescue Errno::ENOENT
  end
end
