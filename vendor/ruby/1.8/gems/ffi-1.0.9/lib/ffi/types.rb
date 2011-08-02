#
# Copyright (C) 2008-2010 Wayne Meissner
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

  def self.typedef(old, add)
    TypeDefs[add] = self.find_type(old)
  end

  def self.add_typedef(old, add)
    typedef old, add
  end


  def self.find_type(name, type_map = nil)
    if name.is_a?(Type)
      name

    elsif type_map && type_map.has_key?(name)
      type_map[name]

    elsif TypeDefs.has_key?(name)
      TypeDefs[name]

    elsif name.is_a?(DataConverter)
      (type_map || TypeDefs)[name] = Type::Mapped.new(name)
    
    else
      raise TypeError, "unable to resolve type '#{name}'"
    end
  end

  TypeDefs.merge!({
      # The C void type; only useful for function return types
      :void => Type::VOID,

      # C boolean type
      :bool => Type::BOOL,

      # C nul-terminated string
      :string => Type::STRING,

      # C signed char
      :char => Type::CHAR,
      # C unsigned char
      :uchar => Type::UCHAR,

      # C signed short
      :short => Type::SHORT,
      # C unsigned short
      :ushort => Type::USHORT,

      # C signed int
      :int => Type::INT,
      # C unsigned int
      :uint => Type::UINT,

      # C signed long
      :long => Type::LONG,

      # C unsigned long
      :ulong => Type::ULONG,

      # C signed long long integer
      :long_long => Type::LONG_LONG,

      # C unsigned long long integer
      :ulong_long => Type::ULONG_LONG,

      # C single precision float
      :float => Type::FLOAT,

      # C double precision float
      :double => Type::DOUBLE,

      # Native memory address
      :pointer => Type::POINTER,

      # 8 bit signed integer
      :int8 => Type::INT8,
      # 8 bit unsigned integer
      :uint8 => Type::UINT8,

      # 16 bit signed integer
      :int16 => Type::INT16,
      # 16 bit unsigned integer
      :uint16 => Type::UINT16,

      # 32 bit signed integer
      :int32 => Type::INT32,
      # 32 bit unsigned integer
      :uint32 => Type::UINT32,

      # 64 bit signed integer
      :int64 => Type::INT64,
      # 64 bit unsigned integer
      :uint64 => Type::UINT64,

      :buffer_in => Type::BUFFER_IN,
      :buffer_out => Type::BUFFER_OUT,
      :buffer_inout => Type::BUFFER_INOUT,

      # Used in function prototypes to indicate the arguments are variadic
      :varargs => Type::VARARGS,
  })

  # Returns a [ String, Pointer ] tuple so the C memory for the string can be freed
  class StrPtrConverter
    extend DataConverter
    native_type Type::POINTER

    def self.from_native(val, ctx)
      [ val.null? ? nil : val.get_string(0), val ]
    end

  end

  typedef(StrPtrConverter, :strptr)

  def self.type_size(type)
    find_type(type).size
  end

  # Load all the platform dependent types
  begin
    File.open(File.join(Platform::CONF_DIR, 'types.conf'), "r") do |f|
      prefix = "rbx.platform.typedef."
      f.each_line { |line|
        if line.index(prefix) == 0
          new_type, orig_type = line.chomp.slice(prefix.length..-1).split(/\s*=\s*/)
          typedef(orig_type.to_sym, new_type.to_sym)
        end
      }
    end
    typedef :pointer, :caddr_t
  rescue Errno::ENOENT
  end
end
