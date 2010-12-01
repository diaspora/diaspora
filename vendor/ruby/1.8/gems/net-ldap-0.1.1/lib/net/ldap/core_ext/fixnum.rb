module Net
  class LDAP
    module Extensions
      module Fixnum
        #
        # to_ber
        #
        def to_ber
          "\002" + to_ber_internal
        end

        #
        # to_ber_enumerated
        #
        def to_ber_enumerated
          "\012" + to_ber_internal
        end

        #
        # to_ber_length_encoding
        #
        def to_ber_length_encoding
          if self <= 127
            [self].pack('C')
          else
            i = [self].pack('N').sub(/^[\0]+/,"")
            [0x80 + i.length].pack('C') + i
          end
        end

        # Generate a BER-encoding for an application-defined INTEGER.
        # Example: SNMP's Counter, Gauge, and TimeTick types.
        #
        def to_ber_application tag
            [0x40 + tag].pack("C") + to_ber_internal
        end

        #--
        # Called internally to BER-encode the length and content bytes of a 
        # Fixnum. The caller will prepend the tag byte.
        #
        MAX_SIZE = 0.size
        def to_ber_internal
          # CAUTION: Bit twiddling ahead. You might want to shield your eyes 
          # or something. 
          
          # Looks for the first byte in the fixnum that is not all zeroes. It
          # does this by masking one byte after another, checking the result
          # for bits that are left on. 
          size = MAX_SIZE
          while size>1
            break if (self & (0xff << (size-1)*8)) > 0 
            size -= 1
          end
          
          # Store the size of the fixnum in the result
          result = [size]

          # Appends bytes to result, starting with higher orders first.
          # Extraction of bytes is done by right shifting the original fixnum
          # by an amount and then masking that with 0xff.
          while size>0
            # right shift size-1 bytes, mask with 0xff 
            result << ((self >> ((size-1)*8)) & 0xff)
            size -= 1
          end

          result.pack('C*')
        end
        private :to_ber_internal
      end
    end
  end
end