class Object #:nodoc:
  # @return <TrueClass, FalseClass>
  #
  # @example [].blank?         #=>  true
  # @example [1].blank?        #=>  false
  # @example [nil].blank?      #=>  false
  #
  # Returns true if the object is nil or empty (if applicable)
  def blank?
    nil? || (respond_to?(:empty?) && empty?)
  end
end

class Numeric #:nodoc:
  # @return <TrueClass, FalseClass>
  #
  # Numerics can't be blank
  def blank?
    false
  end
end

class NilClass #:nodoc:
  # @return <TrueClass, FalseClass>
  #
  # Nils are always blank
  def blank?
    true
  end
end

class TrueClass #:nodoc:
  # @return <TrueClass, FalseClass>
  #
  # True is not blank.
  def blank?
    false
  end
end

class FalseClass #:nodoc:
  # False is always blank.
  def blank?
    true
  end
end

class String #:nodoc:
  # @example "".blank?         #=>  true
  # @example "     ".blank?    #=>  true
  # @example " hey ho ".blank? #=>  false
  #
  # @return <TrueClass, FalseClass>
  #
  # Strips out whitespace then tests if the string is empty.
  def blank?
    strip.empty?
  end
end

class Array
  # Wraps its argument in an array unless it is already an array (or array-like).
  #
  # Specifically:
  #
  # * If the argument is +nil+ an empty list is returned.
  # * Otherwise, if the argument responds to +to_ary+ it is invoked, and its result returned.
  # * Otherwise, returns an array with the argument as its single element.
  #
  #   Array.wrap(nil)       # => []
  #   Array.wrap([1, 2, 3]) # => [1, 2, 3]
  #   Array.wrap(0)         # => [0]
  #
  # This method is similar in purpose to <tt>Kernel#Array</tt>, but there are some differences:
  #
  # * If the argument responds to +to_ary+ the method is invoked. <tt>Kernel#Array</tt>
  # moves on to try +to_a+ if the returned value is +nil+, but <tt>Arraw.wrap</tt> returns
  # such a +nil+ right away.
  # * If the returned value from +to_ary+ is neither +nil+ nor an +Array+ object, <tt>Kernel#Array</tt>
  # raises an exception, while <tt>Array.wrap</tt> does not, it just returns the value.
  # * It does not call +to_a+ on the argument, though special-cases +nil+ to return an empty array.
  #
  # The last point is particularly worth comparing for some enumerables:
  #
  #   Array(:foo => :bar)      # => [[:foo, :bar]]
  #   Array.wrap(:foo => :bar) # => [{:foo => :bar}]
  #
  #   Array("foo\nbar")        # => ["foo\n", "bar"], in Ruby 1.8
  #   Array.wrap("foo\nbar")   # => ["foo\nbar"]
  #
  # There's also a related idiom that uses the splat operator:
  #
  #   [*object]
  #
  # which returns <tt>[nil]</tt> for +nil+, and calls to <tt>Array(object)</tt> otherwise.
  #
  # Thus, in this case the behavior is different for +nil+, and the differences with
  # <tt>Kernel#Array</tt> explained above apply to the rest of +object+s.
  def self.wrap(object)
    if object.nil?
      []
    elsif object.respond_to?(:to_ary)
      object.to_ary
    else
      [object]
    end
  end
end
