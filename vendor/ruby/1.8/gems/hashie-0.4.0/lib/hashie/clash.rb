require 'hashie/hash'

module Hashie
  #
  # A Clash is a "Chainable Lazy Hash". Inspired by libraries such as Arel,
  # a Clash allows you to chain together method arguments to build a 
  # hash, something that's especially useful if you're doing something
  # like constructing a complex options hash. Here's a basic example:
  # 
  #     c = Hashie::Clash.new.conditions(:foo => 'bar').order(:created_at)
  #     c # => {:conditions => {:foo => 'bar'}, :order => :created_at}
  #
  # Clash provides another way to create sub-hashes by using bang notation.
  # You can dive into a sub-hash by providing a key with a bang and dive
  # back out again with the _end! method. Example:
  #
  #     c = Hashie::Clash.new.conditions!.foo('bar').baz(123)._end!.order(:created_at)
  #     c # => {:conditions => {:foo => 'bar', :baz => 123}, :order => :created_at}
  #
  # Because the primary functionality of Clash is to build options objects,
  # all keys are converted to symbols since many libraries expect symbols explicitly
  # for keys.
  #
  class Clash < ::Hash
    class ChainError < ::StandardError; end
    # The parent Clash if this Clash was created via chaining.
    attr_reader :_parent
    
    # Initialize a new clash by passing in a Hash to
    # convert and, optionally, the parent to which this
    # Clash is chained.
    def initialize(other_hash = {}, parent = nil)
      @_parent = parent
      other_hash.each_pair do |k, v|
        self[k.to_sym] = v
      end
    end
    
    # Jump back up a level if you are using bang method
    # chaining. For example:
    #
    # c = Hashie::Clash.new.foo('bar')
    # c.baz!.foo(123) # => c[:baz]
    # c.baz!._end! # => c
    def _end!
      self._parent
    end
    
    def id(*args) #:nodoc:
      method_missing(:id, *args)
    end
    
    def merge_store(key, *args) #:nodoc:
      case args.length
        when 1
          val = args.first
          val = self[key].merge(val) if self[key].is_a?(::Hash) && val.is_a?(::Hash)
        else
          val = args
      end

      self[key.to_sym] = val
      self
    end
    
    def method_missing(name, *args) #:nodoc:
      name = name.to_s
      if name.match(/!$/) && args.empty?
        key = name[0...-1].to_sym
        
        if self[key].nil?
          self[key] = Clash.new({}, self)
        elsif self[key].is_a?(::Hash) && !self[key].is_a?(Clash)
          self[key] = Clash.new(self[key], self)
        else
          raise ChainError, "Tried to chain into a non-hash key."
        end
        
        self[key]
      elsif args.any?
        key = name.to_sym
        self.merge_store(key, *args)
      end
    end
  end
end