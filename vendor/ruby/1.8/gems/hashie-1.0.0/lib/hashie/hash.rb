require 'hashie/hash_extensions'

module Hashie
  # A Hashie Hash is simply a Hash that has convenience
  # functions baked in such as stringify_keys that may
  # not be available in all libraries.
  class Hash < Hash
    include Hashie::HashExtensions

    # Converts a mash back to a hash (with stringified keys)
    def to_hash
      out = {}
      keys.each do |k|
        out[k] = Hashie::Hash === self[k] ? self[k].to_hash : self[k]
      end
      out
    end

    # The C geneartor for the json gem doesn't like mashies
    def to_json(*args)
      to_hash.to_json(*args)
    end
  end
end
