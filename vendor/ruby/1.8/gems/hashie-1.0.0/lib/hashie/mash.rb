require 'hashie/hash'

module Hashie
  # Mash allows you to create pseudo-objects that have method-like
  # accessors for hash keys. This is useful for such implementations
  # as an API-accessing library that wants to fake robust objects
  # without the overhead of actually doing so. Think of it as OpenStruct
  # with some additional goodies.
  #
  # A Mash will look at the methods you pass it and perform operations
  # based on the following rules:
  #
  # * No punctuation: Returns the value of the hash for that key, or nil if none exists.
  # * Assignment (<tt>=</tt>): Sets the attribute of the given method name.
  # * Existence (<tt>?</tt>): Returns true or false depending on whether that key has been set.
  # * Bang (<tt>!</tt>): Forces the existence of this key, used for deep Mashes. Think of it as "touch" for mashes.
  #
  # == Basic Example
  #
  #   mash = Mash.new
  #   mash.name? # => false
  #   mash.name = "Bob"
  #   mash.name # => "Bob"
  #   mash.name? # => true
  #
  # == Hash Conversion  Example
  #
  #   hash = {:a => {:b => 23, :d => {:e => "abc"}}, :f => [{:g => 44, :h => 29}, 12]}
  #   mash = Mash.new(hash)
  #   mash.a.b # => 23
  #   mash.a.d.e # => "abc"
  #   mash.f.first.g # => 44
  #   mash.f.last # => 12
  #
  # == Bang Example
  #
  #   mash = Mash.new
  #   mash.author # => nil
  #   mash.author! # => <Mash>
  #
  #   mash = Mash.new
  #   mash.author!.name = "Michael Bleigh"
  #   mash.author # => <Mash name="Michael Bleigh">
  #
  class Mash < Hashie::Hash
    include Hashie::PrettyInspect
    alias_method :to_s, :inspect

    # If you pass in an existing hash, it will
    # convert it to a Mash including recursively
    # descending into arrays and hashes, converting
    # them as well.
    def initialize(source_hash = nil, default = nil, &blk)
      deep_update(source_hash) if source_hash
      default ? super(default) : super(&blk)
    end

    class << self; alias [] new; end

    def id #:nodoc:
      key?("id") ? self["id"] : super
    end

    alias_method :regular_reader, :[]
    alias_method :regular_writer, :[]=

    # Retrieves an attribute set in the Mash. Will convert
    # any key passed in to a string before retrieving.
    def [](key)
      value = regular_reader(convert_key(key))
      yield value if block_given?
      value
    end

    # Sets an attribute in the Mash. Key will be converted to
    # a string before it is set, and Hashes will be converted
    # into Mashes for nesting purposes.
    def []=(key,value) #:nodoc:
      regular_writer(convert_key(key), convert_value(value))
    end

    # This is the bang method reader, it will return a new Mash
    # if there isn't a value already assigned to the key requested.
    def initializing_reader(key)
      ck = convert_key(key)
      regular_writer(ck, self.class.new) unless key?(ck)
      regular_reader(ck)
    end

    def delete(key)
      super(convert_key(key))
    end

    alias_method :regular_dup, :dup
    # Duplicates the current mash as a new mash.
    def dup
      self.class.new(self, self.default)
    end

    def key?(key)
      super(convert_key(key))
    end

    # Performs a deep_update on a duplicate of the
    # current mash.
    def deep_merge(other_hash)
      dup.deep_update(other_hash)
    end
    alias_method :merge, :deep_merge

    # Recursively merges this mash with the passed
    # in hash, merging each hash in the hierarchy.
    def deep_update(other_hash)
      other_hash.each_pair do |k,v|
        key = convert_key(k)
        if regular_reader(key).is_a?(Mash) and v.is_a?(::Hash)
          regular_reader(key).deep_update(v)
        else
          regular_writer(key, convert_value(v, true))
        end
      end
      self
    end
    alias_method :deep_merge!, :deep_update
    alias_method :update, :deep_update
    alias_method :merge!, :update

    # Performs a shallow_update on a duplicate of the current mash
    def shallow_merge(other_hash)
      dup.shallow_update(other_hash)
    end

    # Merges (non-recursively) the hash from the argument,
    # changing the receiving hash
    def shallow_update(other_hash)
      other_hash.each_pair do |k,v|
        regular_writer(convert_key(k), convert_value(v, true))
      end
      self
    end

   # Will return true if the Mash has had a key
   # set in addition to normal respond_to? functionality.
   def respond_to?(method_name)
     return true if key?(method_name)
     super
   end
   
   def method_missing(method_name, *args, &blk)
     return self.[](method_name, &blk) if key?(method_name)
     match = method_name.to_s.match(/(.*?)([?=!]?)$/)
     case match[2]
     when "="
       self[match[1]] = args.first
     when "?"
       !!self[match[1]]
     when "!"
       initializing_reader(match[1])
     else
       default(method_name, *args, &blk)
     end
   end

    protected

    def convert_key(key) #:nodoc:
      key.to_s
    end

    def convert_value(val, duping=false) #:nodoc:
      case val
        when self.class
          val.dup
        when ::Hash
          val = val.dup if duping
          self.class.new(val)
        when Array
          val.collect{ |e| convert_value(e) }
        else
          val
      end
    end
  end
end
