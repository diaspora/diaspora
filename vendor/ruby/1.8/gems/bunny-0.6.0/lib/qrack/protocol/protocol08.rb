module Qrack
	module Protocol
	  #:stopdoc:
	  class Class::Method
	    def initialize *args
	      opts = args.pop if args.last.is_a? Hash
	      opts ||= {}
      
	      if args.size == 1 and args.first.is_a? Transport::Buffer
	        buf = args.shift
	      else
	        buf = nil
	      end

	      self.class.arguments.each do |type, name|
	        val = buf ? buf.read(type) :
	                    args.shift || opts[name] || opts[name.to_s]
	        instance_variable_set("@#{name}", val)
	      end
	    end

	    def arguments
	      self.class.arguments.inject({}) do |hash, (type, name)|
	        hash.update name => instance_variable_get("@#{name}")
	      end
	    end

	    def to_binary
	      buf = Transport::Buffer.new
	      buf.write :short, self.class.parent.id
	      buf.write :short, self.class.id

	      bits = []

	      self.class.arguments.each do |type, name|
	        val = instance_variable_get("@#{name}")
	        if type == :bit
	          bits << (val || false)
	        else
	          unless bits.empty?
	            buf.write :bit, bits
	            bits = []
	          end
	          buf.write type, val
	        end
	      end

	      buf.write :bit, bits unless bits.empty?
	      buf.rewind

	      buf
	    end
    
	    def to_s
	      to_binary.to_s
	    end
    
	    def to_frame channel = 0
	      Transport::Method.new(self, channel)
	    end
	  end

	  class Header
	    def initialize *args
	      opts = args.pop if args.last.is_a? Hash
	      opts ||= {}
      
	      first = args.shift
      
	      if first.is_a? ::Class and first.ancestors.include? Protocol::Class
	        @klass = first
	        @size = args.shift || 0
	        @weight = args.shift || 0
	        @properties = opts

	      elsif first.is_a? Transport::Buffer or first.is_a? String
	        buf = first
	        buf = Transport::Buffer.new(buf) unless buf.is_a? Transport::Buffer
        
	        @klass = Protocol.classes[buf.read(:short)]
	        @weight = buf.read(:short)
	        @size = buf.read(:longlong)

	        props = buf.read(:properties, *klass.properties.map{|type,_| type })
	        @properties = Hash[*klass.properties.map{|_,name| name }.zip(props).reject{|k,v| v.nil? }.flatten]

	      else
	        raise ArgumentError, 'Invalid argument'
	      end
      
	    end
	    attr_accessor :klass, :size, :weight, :properties
    
	    def to_binary
	      buf = Transport::Buffer.new
	      buf.write :short, klass.id
	      buf.write :short, weight # XXX rabbitmq only supports weight == 0
	      buf.write :longlong, size
	      buf.write :properties, (klass.properties.map do |type, name|
	                               [ type, properties[name] || properties[name.to_s] ]
	                             end)
	      buf.rewind
	      buf
	    end
    
	    def to_s
	      to_binary.to_s
	    end

	    def to_frame channel = 0
	      Transport::Header.new(self, channel)
	    end

	    def == header
	      [ :klass, :size, :weight, :properties ].inject(true) do |eql, field|
	        eql and __send__(field) == header.__send__(field)
	      end
	    end

	    def method_missing meth, *args, &blk
	      @properties.has_key?(meth) || @klass.properties.find{|_,name| name == meth } ? @properties[meth] : super
	    end
	  end

	  def self.parse buf
	    buf = Transport::Buffer.new(buf) unless buf.is_a? Transport::Buffer
	    class_id, method_id = buf.read(:short, :short)
	    classes[class_id].methods[method_id].new(buf)
	  end

	end
end
