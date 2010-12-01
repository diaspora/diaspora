# NET::BER
# Mixes ASN.1/BER convenience methods into several standard classes.
# Also provides BER parsing functionality.
#
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
  module BER
    VERSION = '0.1.0'
    
    #--
    # This condenses our nicely self-documenting ASN hashes down
    # to an array for fast lookups.
    # Scoped to be called as a module method, but not intended for
    # user code to call.
    #    
    def self.compile_syntax(syn)
      out = [nil] * 256
      syn.each do |tclass, tclasses|
        tagclass = {:universal=>0, :application=>64, :context_specific=>128, :private=>192} [tclass]
        tclasses.each do |codingtype,codings|
          encoding = {:primitive=>0, :constructed=>32} [codingtype]
          codings.each {|tag, objtype| out[tagclass + encoding + tag] = objtype }
        end
      end
      out
    end

    def to_ber
      # Provisional implementation.
      # We ASSUME that our incoming value is an array, and we
      # use the Array#to_ber_oid method defined below.
      # We probably should obsolete that method, actually, in
      # and move the code here.
      # WE ARE NOT CURRENTLY ENCODING THE BER-IDENTIFIER.
      # This implementation currently hardcodes 6, the universal OID tag.
      ary = @value.dup
      first = ary.shift
      raise Net::BER::BerError.new(" invalid OID" ) unless [0,1,2].include?(first)
      first = first * 40 + ary.shift
      ary.unshift first
      oid = ary.pack("w*")
      [6, oid.length].pack("CC") + oid
    end
  end
end

module Net
  module BER
    class BerError < StandardError; end
    
    class BerIdentifiedString < String
      attr_accessor :ber_identifier
      def initialize args
        super args
      end
    end
    
    class BerIdentifiedArray < Array
      attr_accessor :ber_identifier
      def initialize(*args)
        super
      end
    end
    
    class BerIdentifiedNull
      attr_accessor :ber_identifier
      def to_ber
        "\005\000"
      end
    end
  end
end

require 'net/ber/ber_parser'
