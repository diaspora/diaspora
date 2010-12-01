require 'extlib/mash'

class Array

  ##
  # Transforms an Array of key/value pairs into a Hash
  #
  # This is a better idiom than using Hash[*array.flatten] in Ruby 1.8.6
  # because it is not possible to limit the flattening to a single
  # level.
  #
  # @return [Hash]
  #   A Hash where each entry in the Array is turned into a key/value
  #
  # @api public
  def to_hash
    h = {}
    each { |k,v| h[k] = v }
    h
  end

  ##
  # Transforms an Array of key/value pairs into a Mash
  #
  # This is a better idiom than using Mash[*array.flatten] in Ruby 1.8.6
  # because it is not possible to limit the flattening to a single
  # level.
  #
  # @return [Mash]
  #   A Hash where each entry in the Array is turned into a key/value
  #
  # @api public
  def to_mash
    m = Mash.new
    each { |k,v| m[k] = v }
    m
  end
end # class Array
