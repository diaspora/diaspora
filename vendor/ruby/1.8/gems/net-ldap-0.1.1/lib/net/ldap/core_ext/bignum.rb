module Net
  class LDAP
    module Extensions
      module Bignum

        def to_ber
          # NOTE: Array#pack's 'w' is a BER _compressed_ integer. We need
          # uncompressed BER integers, so we're not using that. See also:
          # http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/228864
          result = []

          n = self
          while n>0
              b = n & 0xff
              result << b
              n = n >> 8
          end

          "\002" + ([result.size] + result.reverse).pack('C*')
        end

      end
    end
  end
end