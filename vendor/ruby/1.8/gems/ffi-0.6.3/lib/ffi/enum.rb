#
# Copyright (C) 2009 Luc Heinrich
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
    attr_reader :tag

    def initialize(info, tag=nil)
      @tag = tag
      @kv_map = Hash.new
      @vk_map = Hash.new
      unless info.nil?
        last_cst = nil
        value = 0
        info.each do |i|
          case i
          when Symbol
            @kv_map[i] = value
            @vk_map[value] = i
            last_cst = i
            value += 1
          when Integer
            @kv_map[last_cst] = i
            @vk_map[i] = last_cst
            value = i+1
          end
        end
      end
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

  end

end