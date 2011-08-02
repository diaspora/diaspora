#
# Copyright (C) 2008-2010 Wayne Meissner
# Copyright (C) 2008, 2009 Andrea Fazzi
# Copyright (C) 2008, 2009 Luc Heinrich
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

require 'ffi/platform'
require 'ffi/struct_layout_builder'

module FFI

  class StructLayout

    def offsets
      members.map { |m| [ m, self[m].offset ] }
    end

    def offset_of(field_name)
      self[field_name].offset
    end

    class Enum < Field
      
      def get(ptr)
        type.find(ptr.get_int(offset))
      end

      def put(ptr, value)
        ptr.put_int(offset, type.find(value))
      end

    end

    class InnerStruct < Field
      def get(ptr)
        type.struct_class.new(ptr.slice(self.offset, self.size))
      end

#      def put(ptr, value)
#        raise TypeError, "wrong value type (expected #{type.struct_class}" unless value.is_a(type.struct_class)
#      end
    end

    class Mapped < Field
      def initialize(name, offset, type, orig_field)
        super(name, offset, type)
        @orig_field = orig_field
      end

      def get(ptr)
        type.from_native(@orig_field.get(ptr), nil)
      end

      def put(ptr, value)
        @orig_field.put(ptr, type.to_native(value, nil))
      end
    end
  end

  
  class Struct

    def size
      self.class.size
    end

    def alignment
      self.class.alignment
    end
    alias_method :align, :alignment

    def offset_of(name)
      self.class.offset_of(name)
    end

    def members
      self.class.members
    end

    def values
      members.map { |m| self[m] }
    end

    def offsets
      self.class.offsets
    end

    def clear
      pointer.clear
      self
    end

    def to_ptr
      pointer
    end

    def self.size
      defined?(@layout) ? @layout.size : defined?(@size) ? @size : 0
    end

    def self.size=(size)
      raise ArgumentError, "Size already set" if defined?(@size) || defined?(@layout)
      @size = size
    end

    def self.alignment
      @layout.alignment
    end

    def self.align
      @layout.alignment
    end

    def self.members
      @layout.members
    end

    def self.offsets
      @layout.offsets
    end

    def self.offset_of(name)
      @layout.offset_of(name)
    end

    def self.in
      ptr(:in)
    end

    def self.out
      ptr(:out)
    end

    def self.ptr(flags = :inout)
      @ref_data_type ||= Type::Mapped.new(StructByReference.new(self))
    end

    def self.val
      @val_data_type ||= StructByValue.new(self)
    end

    def self.by_value
      self.val
    end

    def self.by_ref(flags = :inout)
      self.ptr(flags)
    end

    class ManagedStructConverter < StructByReference

      def initialize(struct_class)
        super(struct_class)

        raise NoMethodError, "release() not implemented for class #{struct_class}" unless struct_class.respond_to? :release
        @method = struct_class.method(:release)
      end

      def from_native(ptr, ctx)
        struct_class.new(AutoPointer.new(ptr, @method))
      end
    end

    def self.auto_ptr
      @managed_type ||= Type::Mapped.new(ManagedStructConverter.new(self))
    end


    class << self
      public

      def layout(*spec)
#        raise RuntimeError, "struct layout already defined for #{self.inspect}" if defined?(@layout)
        return @layout if spec.size == 0

        builder = StructLayoutBuilder.new
        builder.union = self < Union
        builder.packed = @packed if defined?(@packed)
        builder.alignment = @min_alignment if defined?(@min_alignment)

        if spec[0].kind_of?(Hash)
          hash_layout(builder, spec)
        else
          array_layout(builder, spec)
        end
        builder.size = @size if defined?(@size) && @size > builder.size
        cspec = builder.build
        @layout = cspec unless self == Struct
        @size = cspec.size
        return cspec
      end


      protected

      def callback(params, ret)
        mod = enclosing_module
        FFI::CallbackInfo.new(find_type(ret, mod), params.map { |e| find_type(e, mod) })
      end

      def packed(packed = 1)
        @packed = packed
      end
      alias :pack :packed
      
      def aligned(alignment = 1)
        @min_alignment = alignment
      end
      alias_method :align, :aligned

      def enclosing_module
        begin
          mod = self.name.split("::")[0..-2].inject(Object) { |obj, c| obj.const_get(c) }
          mod.respond_to?(:find_type) ? mod : nil
        rescue Exception => ex
          nil
        end
      end


      def find_field_type(type, mod = enclosing_module)
        if type.kind_of?(Class) && type < Struct
          FFI::Type::Struct.new(type)

        elsif type.kind_of?(Class) && type < FFI::StructLayout::Field
          type

        elsif type.kind_of?(::Array)
          FFI::Type::Array.new(find_field_type(type[0]), type[1])

        else
          find_type(type, mod)
        end
      end

      def find_type(type, mod = enclosing_module)
        if mod
          mod.find_type(type)
        end || FFI.find_type(type)
      end

      private

      def hash_layout(builder, spec)
        raise "Ruby version not supported" if RUBY_VERSION =~ /1.8.*/
        spec[0].each do |name, type|
          builder.add name, find_field_type(type), nil
        end
      end

      def array_layout(builder, spec)
        i = 0
        while i < spec.size
          name, type = spec[i, 2]
          i += 2

          # If the next param is a Integer, it specifies the offset
          if spec[i].kind_of?(Integer)
            offset = spec[i]
            i += 1
          else
            offset = nil
          end

          builder.add name, find_field_type(type), offset
        end
      end
    end
  end
end
