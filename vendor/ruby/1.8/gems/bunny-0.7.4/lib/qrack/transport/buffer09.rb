# encoding: utf-8

if [].map.respond_to? :with_index
  class Array #:nodoc:
    def enum_with_index
      each.with_index
    end
  end
else
  require 'enumerator'
end

module Qrack
  module Transport09 #:nodoc: all
    class Buffer

      def initialize data = ''
        @data = data
        @pos = 0
      end

      attr_reader :pos

      def data
        @data.clone
      end
      alias :contents :data
      alias :to_s :data

      def << data
        @data << data.to_s
        self
      end

      def length
        @data.bytesize
      end

      def empty?
        pos == length
      end

      def rewind
        @pos = 0
      end

      def read_properties *types
        types.shift if types.first == :properties

        i = 0
        values = []

        while props = read(:short)
          (0..14).each do |n|
            # no more property types
            break unless types[i]

            # if flag is set
            if props & (1<<(15-n)) != 0
              if types[i] == :bit
                # bit values exist in flags only
                values << true
              else
                # save type name for later reading
                values << types[i]
              end
            else
              # property not set or is false bit
              values << (types[i] == :bit ? false : nil)
            end

            i+=1
          end

          # bit(0) == 0 means no more property flags
          break unless props & 1 == 1
        end

        values.map do |value|
          value.is_a?(Symbol) ? read(value) : value
        end
      end

      def read *types
        if types.first == :properties
          return read_properties(*types)
        end

        values = types.map do |type|
          case type
          when :octet
            _read(1, 'C')
          when :short
            _read(2, 'n')
          when :long
            _read(4, 'N')
          when :longlong
            upper, lower = _read(8, 'NN')
            upper << 32 | lower
          when :shortstr
            _read read(:octet)
          when :longstr
            _read read(:long)
          when :timestamp
            Time.at read(:longlong)
          when :table
            t = Hash.new

            table = Buffer.new(read(:longstr))
            until table.empty?
              key, type = table.read(:shortstr, :octet)
              key = key.intern
              t[key] ||= case type
                         when 83 # 'S'
                           table.read(:longstr)
                         when 73 # 'I'
                           table.read(:long)
                         when 68 # 'D'
                           exp = table.read(:octet)
                           num = table.read(:long)
                           num / 10.0**exp
                         when 84 # 'T'
                           table.read(:timestamp)
                         when 70 # 'F'
                           table.read(:table)
                         when 116 # 't'
                           table.read(:octet)
                         end
            end

            t
          when :bit
            if (@bits ||= []).empty?
              val = read(:octet)
              @bits = (0..7).map{|i| (val & (1 << i)) != 0 }
            end

            @bits.shift
          else
            raise Qrack::InvalidTypeError, "Cannot read data of type #{type}"
          end
        end

        types.size == 1 ? values.first : values
      end

      def write type, data
        case type
        when :octet
          _write(data, 'C')
        when :short
          _write(data, 'n')
        when :long
          _write(data, 'N')
        when :longlong
          lower =  data & 0xffffffff
          upper = (data & ~0xffffffff) >> 32
          _write([upper, lower], 'NN')
        when :shortstr
          data = (data || '').to_s
          _write([data.bytesize, data], 'Ca*')
        when :longstr
          if data.is_a? Hash
            write(:table, data)
          else
            data = (data || '').to_s
            _write([data.bytesize, data], 'Na*')
          end
        when :timestamp
          write(:longlong, data.to_i)
        when :table
          data ||= {}
          write :longstr, (data.inject(Buffer.new) do |table, (key, value)|
                             table.write(:shortstr, key.to_s)

                             case value
                             when String
                               table.write(:octet, 83) # 'S'
                               table.write(:longstr, value.to_s)
                             when Fixnum
                               table.write(:octet, 73) # 'I'
                               table.write(:long, value)
                             when Float
                               table.write(:octet, 68) # 'D'
                               # XXX there's gotta be a better way to do this..
                               exp = value.to_s.split('.').last.bytesize
                               num = value * 10**exp
                               table.write(:octet, exp)
                               table.write(:long, num)
                             when Time
                               table.write(:octet, 84) # 'T'
                               table.write(:timestamp, value)
                             when Hash
                               table.write(:octet, 70) # 'F'
                               table.write(:table, value)
                             end

                             table
                           end)
        when :bit
          [*data].to_enum(:each_slice, 8).each{|bits|
            write(:octet, bits.enum_with_index.inject(0){ |byte, (bit, i)|
                    byte |= (1 << i) if bit
                    byte
                  })
          }
        when :properties
          values = []
          data.enum_with_index.inject(0) do |short, ((type, value), i)|
            n = i % 15
            last = i+1 == data.size

            if (n == 0 and i != 0) or last
              if data.size > i+1
                short |= (1 << 0)
              elsif last and value
                values << [type,value]
                short |= 1<<(15-n)
              end

              write(:short, short)
              short = 0
            end

            if value and !last
              values << [type,value]
              short |= 1<<(15-n)
            end

            short
          end

          values.each do |type, value|
            write(type, value) unless type == :bit
          end
        else
          raise Qrack::InvalidTypeError, "Cannot write data of type #{type}"
        end

        self
      end

      def extract
        begin
          cur_data, cur_pos = @data.clone, @pos
          yield self
        rescue Qrack::BufferOverflowError
          @data, @pos = cur_data, cur_pos
          nil
        end
      end

      def _read(size, pack = nil)
        if @data.is_a?(Qrack::Client)
          raw = @data.read(size)
          return raw if raw.nil? or pack.nil?
          return raw.unpack(pack).first
        end

        if @pos + size > length
          raise Qrack::BufferOverflowError
        else
          data = @data[@pos,size]
          @data[@pos,size] = ''
          if pack
            data = data.unpack(pack)
            data = data.pop if data.size == 1
          end
          data
        end
      end

      def _write data, pack = nil
        data = [*data].pack(pack) if pack
        @data[@pos,0] = data
        @pos += data.bytesize
      end
    end
  end
end
