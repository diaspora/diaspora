require 'stringio'

module Net
  module BER
    module BERParser
      VERSION = '0.1.0'

      # The order of these follows the class-codes in BER.
      # Maybe this should have been a hash.
      TagClasses = [:universal, :application, :context_specific, :private]

      BuiltinSyntax = Net::BER.compile_syntax( {
    	  :universal => {
     	    :primitive => {
         	  1 => :boolean,
           	2 => :integer,
         		4 => :string,
         		5 => :null,
         		6 => :oid,
         		10 => :integer,
         		13 => :string # (relative OID)
     	    },
     	    :constructed => {
     		    16 => :array,
     		    17 => :array
     	    }
     	  },
     	  :context_specific => {
     	    :primitive => {
     		    10 => :integer
     	    }
     	  }
      })

      def read_ber syntax=nil
        # TODO: clean this up so it works properly with partial
        # packets coming from streams that don't block when
        # we ask for more data (like StringIOs). At it is,
        # this can throw TypeErrors and other nasties.
                
        id = getbyte or return nil  # don't trash this value, we'll use it later

        n = getbyte
        lengthlength,contentlength = if n <= 127
          [1,n]
        else
          # Replaced the inject because it profiles hot.
          #   j = (0...(n & 127)).inject(0) {|mem,x| mem = (mem << 8) + getc}
          j = 0
          read( n & 127 ).each_byte {|n1| j = (j << 8) + n1}
          [1 + (n & 127), j]
        end

        newobj = read contentlength

        # This exceptionally clever and clear bit of code is verrrry slow.
        objtype = (syntax && syntax[id]) || BuiltinSyntax[id]

        # == is expensive so sort this if/else so the common cases are at the top.
        obj = if objtype == :string
          #(newobj || "").dup
          s = BerIdentifiedString.new( newobj || "" )
          s.ber_identifier = id
          s
        elsif objtype == :integer
          j = 0
          newobj.each_byte {|b| j = (j << 8) + b}
          j
        elsif objtype == :oid
          # cf X.690 pgh 8.19 for an explanation of this algorithm.
          # Potentially not good enough. We may need a BerIdentifiedOid
          # as a subclass of BerIdentifiedArray, to get the ber identifier
          # and also a to_s method that produces the familiar dotted notation.
          oid = newobj.unpack("w*")
          f = oid.shift
          g = if f < 40
            [0, f]
          elsif f < 80
            [1, f-40]
          else
            [2, f-80] # f-80 can easily be > 80. What a weird optimization.
          end
          oid.unshift g.last
          oid.unshift g.first
          oid
        elsif objtype == :array
          #seq = []
          seq = BerIdentifiedArray.new
          seq.ber_identifier = id
          sio = StringIO.new( newobj || "" )
          # Interpret the subobject, but note how the loop
          # is built: nil ends the loop, but false (a valid
          # BER value) does not!
          while (e = sio.read_ber(syntax)) != nil
            seq << e
          end
          seq
        elsif objtype == :boolean
          newobj != "\000"
        elsif objtype == :null
          n = BerIdentifiedNull.new
          n.ber_identifier = id
          n
        else
          raise BerError.new( "unsupported object type: id=#{id}" )
        end

        obj
      end
    end
  end
end
