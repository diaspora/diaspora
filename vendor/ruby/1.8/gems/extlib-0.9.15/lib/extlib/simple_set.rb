module Extlib
  # Simple set implementation
  # on top of Hash with merging support.
  #
  # In particular this is used to store
  # a set of callable actions of controller.
  class SimpleSet < Hash

    ##
    # Create a new SimpleSet containing the unique members of _arr_
    #
    # @param [Array] arr Initial set values.
    #
    # @return [Array] The array the Set was initialized with
    #
    # @api public
    def initialize(arr = [])
      Array(arr).each {|x| self[x] = true}
    end

    ##
    # Add a value to the set, and return it
    #
    # @param [Object] value Value to add to set.
    #
    # @return [SimpleSet] Receiver
    #
    # @api public
    def <<(value)
      self[value] = true
      self
    end

    ##
    # Merge _arr_ with receiver, producing the union of receiver & _arr_
    #
    #   s = Extlib::SimpleSet.new([:a, :b, :c])
    #   s.merge([:c, :d, :e, f])  #=> #<SimpleSet: {:e, :c, :f, :a, :d, :b}>
    #
    # @param [Array] arr Values to merge with set.
    #
    # @return [SimpleSet] The set after the Array was merged in.
    #
    # @api public
    def merge(arr)
      super(arr.inject({}) {|s,x| s[x] = true; s })
    end

    ##
    # Get a human readable version of the set.
    #
    #   s = SimpleSet.new([:a, :b, :c])
    #   s.inspect                 #=> "#<SimpleSet: {:c, :a, :b}>"
    #
    # @return [String] A human readable version of the set.
    #
    # @api public
    def inspect
      "#<SimpleSet: {#{keys.map {|x| x.inspect}.join(", ")}}>"
    end

    # def to_a
    alias_method :to_a, :keys

  end # SimpleSet
end # Merb
