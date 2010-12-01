require 'active_support' unless defined?(::ActiveSupport::JSON)

module MultiJson
  module Engines
    # Use ActiveSupport to encode/decode JSON.
    class ActiveSupport
      def self.decode(string, options = {}) #:nodoc:
        hash = ::ActiveSupport::JSON.decode(string)
        options[:symbolize_keys] ? symbolize_keys(hash) : hash
      end

      def self.encode(object) #:nodoc:
        ::ActiveSupport::JSON.encode(object)
      end

      def self.symbolize_keys(hash) #:nodoc:
        hash.inject({}){|result, (key, value)|
          new_key = case key
                    when String then key.to_sym
                    else key
                    end
          new_value = case value
                      when Hash then symbolize_keys(value)
                      else value
                      end
          result[new_key] = new_value
          result
        }
      end
    end
  end
end
