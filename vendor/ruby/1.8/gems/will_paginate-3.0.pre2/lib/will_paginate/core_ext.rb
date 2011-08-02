require 'set'
require 'will_paginate/array'

# helper to check for method existance in ruby 1.8- and 1.9-compatible way
# because `methods`, `instance_methods` and others return strings in 1.8 and symbols in 1.9
#
#   ['foo', 'bar'].include_method?(:foo) # => true
class Array
  def include_method?(name)
    name = name.to_sym
    !!(find { |item| item.to_sym == name })
  end
end

## everything below copied from ActiveSupport so we don't depend on it ##

unless Hash.instance_methods.include_method? :except
  Hash.class_eval do
    # Returns a new hash without the given keys.
    def except(*keys)
      rejected = Set.new(respond_to?(:convert_key) ? keys.map { |key| convert_key(key) } : keys)
      reject { |key,| rejected.include?(key) }
    end
 
    # Replaces the hash without only the given keys.
    def except!(*keys)
      replace(except(*keys))
    end
  end
end

unless Hash.instance_methods.include_method? :slice
  Hash.class_eval do
    # Returns a new hash with only the given keys.
    def slice(*keys)
      allowed = Set.new(respond_to?(:convert_key) ? keys.map { |key| convert_key(key) } : keys)
      reject { |key,| !allowed.include?(key) }
    end

    # Replaces the hash with only the given keys.
    def slice!(*keys)
      replace(slice(*keys))
    end
  end
end

unless String.instance_methods.include_method? :constantize
  String.class_eval do
    def constantize
      unless /\A(?:::)?([A-Z]\w*(?:::[A-Z]\w*)*)\z/ =~ self
        raise NameError, "#{self.inspect} is not a valid constant name!"
      end

      Object.module_eval("::#{$1}", __FILE__, __LINE__)
    end
  end
end

unless String.instance_methods.include_method? :underscore
  String.class_eval do
    def underscore
      self.to_s.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase
    end
  end
end
