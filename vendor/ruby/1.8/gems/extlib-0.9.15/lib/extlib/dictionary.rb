# TITLE:
#
#   Dictionary
#
# AUTHORS:
#
#   - Jan Molic
#   - Thomas Sawyer
#
# CREDIT:
#
#   - Andrew Johnson (merge, to_a, inspect, shift and Hash[])
#   - Jeff Sharpe    (reverse and reverse!)
#   - Thomas Leitner (has_key? and key?)
#
# LICENSE:
#
#   Copyright (c) 2005 Jan Molic, Thomas Sawyer
#
#   Ruby License
#
#   This module is free software. You may use, modify, and/or redistribute this
#   software under the same terms as Ruby.
#
#   This program is distributed in the hope that it will be useful, but WITHOUT
#   ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
#   FOR A PARTICULAR PURPOSE.
#
#   Originally ported from OrderHash 2.0, Copyright (c) 2005 jan molic
#
# LOG:
#
#   - 2007.10.31 trans
#     Fixed initialize so the constructor blocks correctly effected dictionary
#     rather then just the internal hash.

# = Dictionary
#
# The Dictionary class is a Hash that preserves order.
# So it has some array-like extensions also. By defualt
# a Dictionary object preserves insertion order, but any
# order can be specified including alphabetical key order.
#
# == Usage
#
# Just require this file and use Dictionary instead of Hash.
#
#   # You can do simply
#   hsh = Dictionary.new
#   hsh['z'] = 1
#   hsh['a'] = 2
#   hsh['c'] = 3
#   p hsh.keys     #=> ['z','a','c']
#
#   # or using Dictionary[] method
#   hsh = Dictionary['z', 1, 'a', 2, 'c', 3]
#   p hsh.keys     #=> ['z','a','c']
#
#   # but this doesn't preserve order
#   hsh = Dictionary['z'=>1, 'a'=>2, 'c'=>3]
#   p hsh.keys     #=> ['a','c','z']
#
#   # Dictionary has useful extensions: push, pop and unshift
#   p hsh.push('to_end', 15)       #=> true, key added
#   p hsh.push('to_end', 30)       #=> false, already - nothing happen
#   p hsh.unshift('to_begin', 50)  #=> true, key added
#   p hsh.unshift('to_begin', 60)  #=> false, already - nothing happen
#   p hsh.keys                     #=> ["to_begin", "a", "c", "z", "to_end"]
#   p hsh.pop                      #=> ["to_end", 15], if nothing remains, return nil
#   p hsh.keys                     #=> ["to_begin", "a", "c", "z"]
#   p hsh.shift                    #=> ["to_begin", 30], if nothing remains, return nil
#
# == Usage Notes
#
# * You can use #order_by to set internal sort order.
# * #<< takes a two element [k,v] array and inserts.
# * Use ::auto which creates Dictionay sub-entries as needed.
# * And ::alpha which creates a new Dictionary sorted by key.

class Dictionary

  include Enumerable

  class << self
    #--
    # TODO is this needed? Doesn't the super class do this?
    #++
    def [](*args)
      hsh = new
      if Hash === args[0]
        hsh.replace(args[0])
      elsif (args.size % 2) != 0
        raise ArgumentError, "odd number of elements for Hash"
      else
        while !args.empty?
          hsh[args.shift] = args.shift
        end
      end
      hsh
    end

    # Like #new but the block sets the order.
    #
    def new_by(*args, &blk)
      new(*args).order_by(&blk)
    end

    # Alternate to #new which creates a dictionary sorted by key.
    #
    #   d = Dictionary.alpha
    #   d["z"] = 1
    #   d["y"] = 2
    #   d["x"] = 3
    #   d  #=> {"x"=>3,"y"=>2,"z"=>2}
    #
    # This is equivalent to:
    #
    #   Dictionary.new.order_by { |key,value| key }
    def alpha(*args, &block)
      new(*args, &block).order_by_key
    end

    # Alternate to #new which auto-creates sub-dictionaries as needed.
    #
    #   d = Dictionary.auto
    #   d["a"]["b"]["c"] = "abc"  #=> { "a"=>{"b"=>{"c"=>"abc"}}}
    #
    def auto(*args)
      #AutoDictionary.new(*args)
      leet = lambda { |hsh, key| hsh[key] = new(&leet) }
      new(*args, &leet)
    end
  end

   # New Dictiionary.
  def initialize(*args, &blk)
    @order = []
    @order_by = nil
    if blk
      dict = self                                  # This ensure autmatic key entry effect the
      oblk = lambda{ |hsh, key| blk[dict,key] }    # dictionary rather then just the interal hash.
      @hash = Hash.new(*args, &oblk)
    else
      @hash = Hash.new(*args)
    end
  end

  def order
    reorder if @order_by
    @order
  end

  # Keep dictionary sorted by a specific sort order.
  def order_by( &block )
    @order_by = block
    order
    self
  end

  # Keep dictionary sorted by key.
  #
  #   d = Dictionary.new.order_by_key
  #   d["z"] = 1
  #   d["y"] = 2
  #   d["x"] = 3
  #   d  #=> {"x"=>3,"y"=>2,"z"=>2}
  #
  # This is equivalent to:
  #
  #   Dictionary.new.order_by { |key,value| key }
  #
  # The initializer Dictionary#alpha also provides this.
  def order_by_key
    @order_by = lambda { |k,v| k }
    order
    self
  end

  # Keep dictionary sorted by value.
  #
  #   d = Dictionary.new.order_by_value
  #   d["z"] = 1
  #   d["y"] = 2
  #   d["x"] = 3
  #   d  #=> {"x"=>3,"y"=>2,"z"=>2}
  #
  # This is equivalent to:
  #
  #   Dictionary.new.order_by { |key,value| value }
  def order_by_value
    @order_by = lambda { |k,v| v }
    order
    self
  end

  #
  def reorder
    if @order_by
      assoc = @order.collect{ |k| [k,@hash[k]] }.sort_by(&@order_by)
      @order = assoc.collect{ |k,v| k }
    end
    @order
  end

  def ==(hsh2)
    if hsh2.is_a?( Dictionary )
      @order == hsh2.order &&
      @hash  == hsh2.instance_variable_get("@hash")
    else
      false
    end
  end

  def [] k
    @hash[ k ]
  end

  def fetch(k, *a, &b)
    @hash.fetch(k, *a, &b)
  end

  # Store operator.
  #
  #   h[key] = value
  #
  # Or with additional index.
  #
  #  h[key,index] = value
  def []=(k, i=nil, v=nil)
    if v
      insert(i,k,v)
    else
      store(k,i)
    end
  end

  def insert( i,k,v )
    @order.insert( i,k )
    @hash.store( k,v )
  end

  def store( a,b )
    @order.push( a ) unless @hash.has_key?( a )
    @hash.store( a,b )
  end

  def clear
    @order = []
    @hash.clear
  end

  def delete( key )
    @order.delete( key )
    @hash.delete( key )
  end

  def each_key
    order.each { |k| yield( k ) }
    self
  end

  def each_value
    order.each { |k| yield( @hash[k] ) }
    self
  end

  def each
    order.each { |k| yield( k,@hash[k] ) }
    self
  end
  alias each_pair each

  def delete_if
    order.clone.each { |k| delete k if yield(k,@hash[k]) }
    self
  end

  def values
    ary = []
    order.each { |k| ary.push @hash[k] }
    ary
  end

  def keys
    order
  end

  def invert
    hsh2 = self.class.new
    order.each { |k| hsh2[@hash[k]] = k }
    hsh2
  end

  def reject( &block )
    self.dup.delete_if(&block)
  end

  def reject!( &block )
    hsh2 = reject(&block)
    self == hsh2 ? nil : hsh2
  end

  def replace( hsh2 )
    @order = hsh2.order
    @hash = hsh2.hash
  end

  def shift
    key = order.first
    key ? [key,delete(key)] : super
  end

  def unshift( k,v )
    unless @hash.include?( k )
      @order.unshift( k )
      @hash.store( k,v )
      true
    else
      false
    end
  end

  def <<(kv)
    push( *kv )
  end

  def push( k,v )
    unless @hash.include?( k )
      @order.push( k )
      @hash.store( k,v )
      true
    else
      false
    end
  end

  def pop
    key = order.last
    key ? [key,delete(key)] : nil
  end

  def inspect
    ary = []
    each {|k,v| ary << k.inspect + "=>" + v.inspect}
    '{' + ary.join(", ") + '}'
  end

  def dup
    a = []
    each{ |k,v| a << k; a << v }
    self.class[*a]
  end

  def update( hsh2 )
    hsh2.each { |k,v| self[k] = v }
    reorder
    self
  end
  alias :merge! update

  def merge( hsh2 )
    self.dup.update(hsh2)
  end

  def select
    ary = []
    each { |k,v| ary << [k,v] if yield k,v }
    ary
  end

  def reverse!
    @order.reverse!
    self
  end

  def reverse
    dup.reverse!
  end

  def first
    @hash[order.first]
  end

  def last
    @hash[order.last]
  end

  def length
    @order.length
  end
  alias :size :length

  def empty?
    @hash.empty?
  end

  def has_key?(key)
    @hash.has_key?(key)
  end

  def key?(key)
    @hash.key?(key)
  end

  def to_a
    ary = []
    each { |k,v| ary << [k,v] }
    ary
  end

  def to_json
    buf = "["
    map do |k,v|
      buf << k.to_json
      buf << ", "
      buf << v.to_json
    end.join(", ")
    buf << "]"
    buf
  end

  def to_s
    self.to_a.to_s
  end

  def to_hash
    @hash.dup
  end

  def to_h
    @hash.dup
  end
end
