module WebMock
  module Util
    class HashKeysStringifier
      
      def self.stringify_keys!(arg)
        case arg
        when Array
          arg.map { |elem| stringify_keys!(elem) }
        when Hash
          Hash[
            *arg.map { |key, value|  
              k = key.is_a?(Symbol) ? key.to_s : key
              v = stringify_keys!(value)
              [k,v]
            }.inject([]) {|r,x| r + x}]
        else
          arg
        end
      end
      
    end
  end
end