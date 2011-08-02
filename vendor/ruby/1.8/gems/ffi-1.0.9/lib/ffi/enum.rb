#
# Copyright (C) 2009, 2010 Wayne Meissner
# Copyright (C) 2009 Luc Heinrich
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

  class Enums

    def initialize
      @all_enums = Array.new
      @tagged_enums = Hash.new
      @symbol_map = Hash.new
    end

    def <<(enum)
      @all_enums << enum
      @tagged_enums[enum.tag] = enum unless enum.tag.nil?
      @symbol_map.merge!(enum.symbol_map)
    end

    def find(query)
      if @tagged_enums.has_key?(query)
        @tagged_enums[query]
      else
        @all_enums.detect { |enum| enum.symbols.include?(query) }
      end
    end

    def __map_symbol(symbol)
      @symbol_map[symbol]
    end

  end

  class Enum
    include DataConverter

    attr_reader :tag

    def initialize(info, tag=nil)
      @tag = tag
      @kv_map = Hash.new
      unless info.nil?
        last_cst = nil
        value = 0
        info.each do |i|
          case i
          when Symbol
            @kv_map[i] = value
            last_cst = i
            value += 1
          when Integer
            @kv_map[last_cst] = i
            value = i+1
          end
        end
      end
      @vk_map = Hash[@kv_map.map{|k,v| [v,k]}]
    end

    def symbols
      @kv_map.keys
    end

    def [](query)
      case query
      when Symbol
        @kv_map[query]
      when Integer
        @vk_map[query]
      end
    end
    alias find []

    def symbol_map
      @kv_map
    end
    
    alias to_h symbol_map
    alias to_hash symbol_map

    def native_type
      Type::INT
    end

    def to_native(val, ctx)
      @kv_map[val] || if val.is_a?(Integer)
        val
      elsif val.respond_to?(:to_int)
        val.to_int
      else
        raise ArgumentError, "invalid enum value, #{val.inspect}"
      end
    end

    def from_native(val, ctx)
      @vk_map[val] || val
    end

  end

end
