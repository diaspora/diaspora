# Most objects are cloneable, but not all. For example you can't dup +nil+:
#
#   nil.dup # => TypeError: can't dup NilClass
#
# Classes may signal their instances are not duplicable removing +dup+/+clone+
# or raising exceptions from them. So, to dup an arbitrary object you normally
# use an optimistic approach and are ready to catch an exception, say:
#
#   arbitrary_object.dup rescue object
#
# Rails dups objects in a few critical spots where they are not that arbitrary.
# That rescue is very expensive (like 40 times slower than a predicate), and it
# is often triggered.
#
# That's why we hardcode the following cases and check duplicable? instead of
# using that rescue idiom.
class Object
  # Can you safely .dup this object?
  # False for nil, false, true, symbols, numbers, class and module objects; true otherwise.
  def duplicable?
    true
  end
end

class NilClass #:nodoc:
  def duplicable?
    false
  end
end

class FalseClass #:nodoc:
  def duplicable?
    false
  end
end

class TrueClass #:nodoc:
  def duplicable?
    false
  end
end

class Symbol #:nodoc:
  def duplicable?
    false
  end
end

class Numeric #:nodoc:
  def duplicable?
    false
  end
end

class Class #:nodoc:
  def duplicable?
    false
  end
end

class Module #:nodoc:
  def duplicable?
    false
  end
end
