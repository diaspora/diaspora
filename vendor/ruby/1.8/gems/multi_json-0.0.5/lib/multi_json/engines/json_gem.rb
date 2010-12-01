require 'json' unless defined?(::JSON)

module MultiJson
  module Engines
    # Use the JSON gem to encode/decode.
    class JsonGem
      def self.decode(string, options = {}) #:nodoc:
        opts = {}
        opts[:symbolize_names] = options[:symbolize_keys]
        ::JSON.parse(string, opts)
      end

      def self.encode(object) #:nodoc:
        object.to_json
      end
    end
  end
end
