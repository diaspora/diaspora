module Hashie
  module HashExtensions
    def self.included(base)
      # Don't tread on existing extensions of Hash by
      # adding methods that are likely to exist.
      %w(stringify_keys stringify_keys!).each do |hashie_method|
        base.send :alias_method, hashie_method, "hashie_#{hashie_method}" unless base.instance_methods.include?(hashie_method)
      end
    end

    # Destructively convert all of the keys of a Hash
    # to their string representations.
    def hashie_stringify_keys!
      self.keys.each do |k|
        unless String === k
          self[k.to_s] = self.delete(k)
        end
      end
      self
    end

    # Convert all of the keys of a Hash
    # to their string representations.
    def hashie_stringify_keys
      self.dup.stringify_keys!
    end

    # Convert this hash into a Mash
    def to_mash
      ::Hashie::Mash.new(self)
    end
  end

  module PrettyInspect
    def self.included(base)
      base.send :alias_method, :hash_inspect, :inspect
      base.send :alias_method, :inspect, :hashie_inspect
    end

    def hashie_inspect
      ret = "<##{self.class.to_s}"
      stringify_keys.keys.sort.each do |key|
        ret << " #{key}=#{self[key].inspect}"
      end
      ret << ">"
      ret
    end
  end
end
