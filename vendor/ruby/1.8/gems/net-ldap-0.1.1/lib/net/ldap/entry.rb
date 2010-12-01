# LDAP Entry (search-result) support classes
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
#

module Net
class LDAP


  # Objects of this class represent individual entries in an LDAP directory.
  # User code generally does not instantiate this class. Net::LDAP#search
  # provides objects of this class to user code, either as block parameters or
  # as return values.
  #
  # In LDAP-land, an "entry" is a collection of attributes that are uniquely
  # and globally identified by a DN ("Distinguished Name"). Attributes are
  # identified by short, descriptive words or phrases. Although a directory is
  # free to implement any attribute name, most of them follow rigorous
  # standards so that the range of commonly-encountered attribute names is not
  # large.
  #
  # An attribute name is case-insensitive. Most directories also restrict the
  # range of characters allowed in attribute names. To simplify handling
  # attribute names, Net::LDAP::Entry internally converts them to a standard
  # format. Therefore, the methods which take attribute names can take Strings
  # or Symbols, and work correctly regardless of case or capitalization.
  #
  # An attribute consists of zero or more data items called <i>values.</i> An
  # entry is the combination of a unique DN, a set of attribute names, and a
  # (possibly-empty) array of values for each attribute.
  #
  # Class Net::LDAP::Entry provides convenience methods for dealing with LDAP
  # entries. In addition to the methods documented below, you may access
  # individual attributes of an entry simply by giving the attribute name as
  # the name of a method call. For example:
  #
  #   ldap.search( ... ) do |entry|
  #     puts "Common name: #{entry.cn}"
  #     puts "Email addresses:"
  #     entry.mail.each {|ma| puts ma}
  #   end
  #
  # If you use this technique to access an attribute that is not present in a
  # particular Entry object, a NoMethodError exception will be raised.
  #
  #--
  # Ugly problem to fix someday: We key off the internal hash with a canonical
  # form of the attribute name: convert to a string, downcase, then take the
  # symbol. Unfortunately we do this in at least three places. Should do it in
  # ONE place.
  #
  class Entry
    # This constructor is not generally called by user code.
    #
    def initialize dn = nil # :nodoc:
      @myhash = {}
      @myhash[:dn] = [dn]
    end

    def _dump depth
      to_ldif
    end

    class << self
      def _load entry
        from_single_ldif_string entry
      end
    end

    #--
    # Discovered bug, 26Aug06: I noticed that we're not converting the
    # incoming value to an array if it isn't already one.
    def []=(name, value) # :nodoc:
      sym = attribute_name(name)
      value = [value] unless value.is_a?(Array)
      @myhash[sym] = value
    end

    #--
    # We have to deal with this one as we do with []= because this one and not
    # the other one gets called in formulations like entry["CN"] << cn.
    #
    def [](name) # :nodoc:
      name = attribute_name(name) unless name.is_a?(Symbol)
      @myhash[name] || []
    end

    # Returns the dn of the Entry as a String.
    def dn
      self[:dn][0].to_s
    end

    # Returns an array of the attribute names present in the Entry.
    def attribute_names
      @myhash.keys
    end

    # Accesses each of the attributes present in the Entry.
    # Calls a user-supplied block with each attribute in turn,
    # passing two arguments to the block: a Symbol giving
    # the name of the attribute, and a (possibly empty)
    # Array of data values.
    #
    def each
      if block_given?
        attribute_names.each {|a|
          attr_name,values = a,self[a]
          yield attr_name, values
        }
      end
    end

    alias_method :each_attribute, :each

    # Converts the Entry to a String, representing the
    # Entry's attributes in LDIF format.
    #--
    def to_ldif
      ary = []
      ary << "dn: #{dn}\n"
      v2 = "" # temp value, save on GC
      each_attribute do |k,v|
        unless k == :dn
          v.each {|v1|
            v2 = if (k == :userpassword) || is_attribute_value_binary?(v1)
              ": #{Base64.encode64(v1).chomp.gsub(/\n/m,"\n ")}"
            else
              " #{v1}"
            end
            ary << "#{k}:#{v2}\n"
          }
        end
      end
      ary << "\n"
      ary.join
    end

    #--
    # TODO, doesn't support broken lines.
    # It generates a SINGLE Entry object from an incoming LDIF stream which is
    # of course useless for big LDIF streams that encode many objects.
    #
    # DO NOT DOCUMENT THIS METHOD UNTIL THESE RESTRICTIONS ARE LIFTED.
    #
    # As it is, it's useful for unmarshalling objects that we create, but not
    # for reading arbitrary LDIF files. Eventually, we should have a class
    # method that parses large LDIF streams into individual LDIF blocks
    # (delimited by blank lines) and passes them here.
    #
    class << self
      def from_single_ldif_string ldif
        entry = Entry.new
        entry[:dn] = []
        ldif.split(/\r?\n/m).each {|line|
          break if line.length == 0
          if line =~ /\A([\w]+):(:?)[\s]*/
            entry[$1] <<= if $2 == ':'
              Base64.decode64($')
            else
              $'
            end
          end
        }
        entry.dn ? entry : nil
      end
    end
    
    #--
    # Part of the support for getter and setter style access to attributes. 
    #
    def respond_to?(sym)
      name = attribute_name(sym)
      return true if valid_attribute?(name)
      return super
    end

    #--
    # Supports getter and setter style access for all the attributes that this
    # entry holds.
    #
    def method_missing sym, *args, &block # :nodoc:
      name = attribute_name(sym)
      
      if valid_attribute? name 
        if setter?(sym) && args.size == 1
          value = args.first
          value = [value] unless value.instance_of?(Array)
          self[name]= value

          return value
        elsif args.empty?
          return self[name]
        end
      end
      
      super
    end

    def write
    end

  private

    #--
    # Internal convenience method. It seems like the standard
    # approach in most LDAP tools to base64 encode an attribute
    # value if its first or last byte is nonprintable, or if
    # it's a password. But that turns out to be not nearly good
    # enough. There are plenty of A/D attributes that are binary
    # in the middle. This is probably a nasty performance killer.
    def is_attribute_value_binary? value
      v = value.to_s
      v.each_byte {|byt|
        return true if (byt < 32) || (byt > 126)
      }
      if v[0..0] == ':' or v[0..0] == '<'
        return true
      end
      false
    end
  
    # Returns the symbol that can be used to access the attribute that
    # sym_or_str designates.
    #
    def attribute_name(sym_or_str)
      str = sym_or_str.to_s.downcase
      
      # Does str match 'something='? Still only returns :something
      return str[0...-1].to_sym if str.size>1 && str[-1] == ?=
      return str.to_sym
    end
    
    # Given a valid attribute symbol, returns true. 
    #
    def valid_attribute?(attr_name)
      attribute_names.include?(attr_name)
    end
    
    def setter?(sym)
      sym.to_s[-1] == ?=
    end
  end # class Entry


end # class LDAP
end # module Net
