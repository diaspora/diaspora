begin
  require "rufus/tokyo/tyrant"
rescue LoadError
  puts "You need the rufus gem to use the Tyrant moneta store"
  exit
end

module Moneta
  class Tyrant < ::Rufus::Tokyo::Tyrant
    include Defaults
    
    module Implementation
      def initialize(options = {})
        host = options[:host]
        port = options[:port]
        super(host, port)
      end      
      
      def key?(key)
        !!self[key]
      end
    
      def [](key)
        if val = super
          Marshal.load(val.unpack("m")[0])
        end
      end
    
      def []=(key, value)
        super(key, [Marshal.dump(value)].pack("m"))
      end    
    end
    
    include Implementation
    include Expires
    
    def initialize(options = {})
      super
      @expiration = Expiration.new(options)
    end
    
    class Expiration < ::Rufus::Tokyo::Tyrant
      include Implementation
      
      def [](key)
        super("#{key}__expiration")
      end
      
      def []=(key, value)
        super("#{key}__expiration", value)
      end
      
      def delete(key)
        super("#{key}__expiration")
      end
    end
  end  
end