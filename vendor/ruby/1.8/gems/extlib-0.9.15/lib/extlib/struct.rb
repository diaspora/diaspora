class Struct
  ##
  # Get a hash with names and values of all instance variables.
  #
  #   class Foo < Struct.new(:name, :age, :gender); end
  #   f = Foo.new("Jill", 50, :female)
  #   f.attributes   #=> {:name => "Jill", :age => 50, :gender => :female}
  #
  # @return [Hash] Hash of instance variables in receiver, keyed by ivar name
  #
  # @api public
  def attributes
    h = {}
    each_pair { |k,v| h[k] = v }
    h
  end
end # class Struct
