class Lousy_inspect
  attr_accessor :var
  def inspect    # An unhelpful inspect
    throw "Foo"  # Raises an exception
  end
  def initialize
    @var = 'initialized'
  end
end
class Lousy_inspect_and_to_s
  attr_accessor :var
  def inspect    # An unhelpful inspect
    throw "Foo"  # Raises an exception
  end
  def to_s       # An unhelpful to_s
    throw "bar"  # Raises an exception
  end
  def initialize
    @var = 'initialized'  # Something to inspect
  end
end

# Something that will be passed objects with
# bad inspect or to_s methods
class UnsuspectingClass
  @@Const = 'A constant'
  @@var = 'a class variable'
  def initialize(a)
    @a = a      # "info locals" will try to use
                # inspect or to_s here
    @b = 5
  end
end
def test_Lousy_inspect
  x = Lousy_inspect.new
  return x
end
def test_lousy_inspect_and_to_s
  x = Lousy_inspect_and_to_s.new
  return x
end
x = test_Lousy_inspect
y = test_lousy_inspect_and_to_s
UnsuspectingClass.new(10)
UnsuspectingClass.new(x)
UnsuspectingClass.new(y)
y = 2
