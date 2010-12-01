#----------------------------------------------------------------------------
#
# Copyright (C) 2006 by Francis Cianfrocca. All Rights Reserved.
#
# Gmail: garbagecat10
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#
#---------------------------------------------------------------------------

module Net
  class LDAP
    class Dataset < Hash
      attr_reader :comments

      class IOFilter
        def initialize(io)
          @io = io
        end
        def gets
          s = @io.gets
          s.chomp if s
        end
      end

      def self.read_ldif io
        ds = Dataset.new
        io = IOFilter.new(io)

        line = io.gets
        dn = nil

        while line
          new_line = io.gets
          if new_line =~ /^[\s]+/
            line << " " << $'
          else
            nextline = new_line

            if line =~ /^\#/
              ds.comments << line
            elsif line =~ /^dn:[\s]*/i
              dn = $'
              ds[dn] = Hash.new {|k,v| k[v] = []}
            elsif line.length == 0
              dn = nil
            elsif line =~ /^([^:]+):([\:]?)[\s]*/
              # $1 is the attribute name
              # $2 is a colon iff the attr-value is base-64 encoded
              # $' is the attr-value
              # Avoid the Base64 class because not all Ruby versions have it.
              attrvalue = ($2 == ":") ? $'.unpack('m').shift : $'
              ds[dn][$1.downcase.intern] << attrvalue
            end

            line = nextline
          end
        end

        ds
      end


      def initialize
        @comments = []
      end


      def to_ldif
        ary = []
        ary += (@comments || [])
        keys.sort.each do |dn|
          ary << "dn: #{dn}"

          self[dn].keys.map {|sym| sym.to_s}.sort.each do |attr|
            self[dn][attr.intern].each {|val| ary << "#{attr}: #{val}" }
          end

          ary << ""
        end
        block_given? and ary.each {|line| yield line}
        ary
      end

    end 
  end 
end
