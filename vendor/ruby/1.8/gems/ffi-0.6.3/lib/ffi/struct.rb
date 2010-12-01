#
# Copyright (C) 2008, 2009 Wayne Meissner
# Copyright (C) 2008, 2009 Andrea Fazzi
# Copyright (C) 2008, 2009 Luc Heinrich
#
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

require 'ffi/platform'
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

    class InlineStruct < Field
      def get(ptr)
        type.struct_class.new(ptr.slice(self.offset, self.size))
      end

#      def put(ptr, value)
#        raise TypeError, "wrong value type (expected #{type.struct_class}" unless value.is_a(type.struct_class)
#      end
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
      :buffer_in
    end

    def self.out
      :buffer_out
    end

    def self.by_value
      ::FFI::StructByValue.new(self)
    end



    class << self
      public

      def layout(*spec)
        return @layout if spec.size == 0

        builder = FFI::StructLayoutBuilder.new
        builder.union = self < Union
        if spec[0].kind_of?(Hash)
          hash_layout(builder, spec)
        else
          array_layout(builder, spec)
        end
        builder.size = @size if defined?(@size) && @size > builder.size
        cspec = builder.build
        @layout = cspec unless self == FFI::Struct
        @size = cspec.size
        return cspec
      end


      protected

      def callback(params, ret)
        mod = enclosing_module
        FFI::CallbackInfo.new(find_type(ret, mod), params.map { |e| find_type(e, mod) })
      end


      def enclosing_module
        begin
          mod = self.name.split("::")[0..-2].inject(Object) { |obj, c| obj.const_get(c) }
          mod.respond_to?(:find_type) ? mod : nil
        rescue Exception => ex
          nil
        end
      end

      def find_type(type, mod = nil)
        if type.kind_of?(Class) && type < FFI::Struct
          FFI::Type::Struct.new(type)
        elsif type.is_a?(::Array)
          type
        elsif mod
          mod.find_type(type)
        end || FFI.find_type(type)
      end


      private

      def hash_layout(builder, spec)
        raise "Ruby version not supported" if RUBY_VERSION =~ /1.8.*/
        mod = enclosing_module
        spec[0].each do |name,type|
          if type.kind_of?(Class) && type < Struct
            builder.add_struct(name, type)
          elsif type.kind_of?(::Array)
            builder.add_array(name, find_type(type[0], mod), type[1])
          else
            builder.add_field(name, find_type(type, mod))
          end
        end
      end

      def array_layout(builder, spec)
        mod = enclosing_module
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
          if type.kind_of?(Class) && type < Struct
            builder.add_struct(name, type, offset)
          elsif type.kind_of?(::Array)
            builder.add_array(name, find_type(type[0], mod), type[1], offset)
          else
            builder.add_field(name, find_type(type, mod), offset)
          end
        end
      end
    end
  end
end
