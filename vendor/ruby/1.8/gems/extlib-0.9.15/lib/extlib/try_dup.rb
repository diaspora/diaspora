class Object
  # Override this in a child if it cannot be dup'ed
  #
  # @return [Object]
  def try_dup
    self.dup
  end
end

class TrueClass
  def try_dup
    self
  end
end

class FalseClass
  def try_dup
    self
  end
end

class Module
  def try_dup
    self
  end
end

class NilClass
  def try_dup
    self
  end
end

class Numeric
  def try_dup
    self
  end
end

class Symbol
  def try_dup
    self
  end
end
