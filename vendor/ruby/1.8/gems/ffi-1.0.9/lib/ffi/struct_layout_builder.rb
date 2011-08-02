#
# Copyright (C) 2008-2010 Wayne Meissner
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
  class StructLayoutBuilder
    attr_reader :size, :alignment
    
    def initialize
      @size = 0
      @alignment = 1
      @min_alignment = 1
      @packed = false
      @union = false
      @fields = Array.new
    end

    def size=(size)
      @size = size if size > @size
    end

    def alignment=(align)
      @alignment = align if align > @alignment
      @min_alignment = align
    end

    def union=(is_union)
      @union = is_union
    end

    def union?
      @union
    end

    def packed=(packed)
      if packed.is_a?(Fixnum)
        @alignment = packed
        @packed = packed
      else
        @packed = packed ? 1 : 0
      end
    end


    NUMBER_TYPES = [
      Type::INT8,
      Type::UINT8,
      Type::INT16,
      Type::UINT16,
      Type::INT32,
      Type::UINT32,
      Type::LONG,
      Type::ULONG,
      Type::INT64,
      Type::UINT64,
      Type::FLOAT32,
      Type::FLOAT64,
    ]

    def add(name, type, offset = nil)

      if offset.nil? || offset == -1
        offset = @union ? 0 : align(@size, @packed ? [ @packed, type.alignment ].min : [ @min_alignment, type.alignment ].max)
      end

      #
      # If a FFI::Type type was passed in as the field arg, try and convert to a StructLayout::Field instance
      #
      field = type.is_a?(StructLayout::Field) ? type : field_for_type(name, offset, type)
      @fields << field
      @alignment = [ @alignment, field.alignment ].max unless @packed
      @size = [ @size, field.size + (@union ? 0 : field.offset) ].max

      return self
    end

    def add_field(name, type, offset = nil)
      add(name, type, offset)
    end
    
    def add_struct(name, type, offset = nil)
      add(name, Type::Struct.new(type), offset)
    end

    def add_array(name, type, count, offset = nil)
      add(name, Type::Array.new(type, count), offset)
    end

    def build
      # Add tail padding if the struct is not packed
      size = @packed ? @size : align(@size, @alignment)
      
      StructLayout.new(@fields, size, @alignment)
    end

    private
    
    def align(offset, align)
      align + ((offset - 1) & ~(align - 1));
    end

    def field_for_type(name, offset, type)
      field_class = case
      when type.is_a?(Type::Function)
        StructLayout::Function

      when type.is_a?(Type::Struct)
        StructLayout::InnerStruct

      when type.is_a?(Type::Array)
        StructLayout::Array

      when type.is_a?(FFI::Enum)
        StructLayout::Enum

      when NUMBER_TYPES.include?(type)
        StructLayout::Number

      when type == Type::POINTER
        StructLayout::Pointer

      when type == Type::STRING
        StructLayout::String

      when type.is_a?(Class) && type < StructLayout::Field
        type

      when type.is_a?(DataConverter)
        return StructLayout::Mapped.new(name, offset, Type::Mapped.new(type), field_for_type(name, offset, type.native_type))

      when type.is_a?(Type::Mapped)
        return StructLayout::Mapped.new(name, offset, type, field_for_type(name, offset, type.native_type))

      else
        raise TypeError, "invalid struct field type #{type.inspect}"
      end

      field_class.new(name, offset, type)
    end
  end

end