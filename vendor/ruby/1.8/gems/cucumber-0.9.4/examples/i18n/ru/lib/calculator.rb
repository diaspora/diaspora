# encoding: utf-8

class Calculator
  def initialize
    @stack = []
  end

  def push(arg)
    @stack.push arg
  end

  def result
    @stack.last
  end

  def +
    @stack.push @stack.pop + @stack.pop
  end

  def /
    divisor, dividend = [@stack.pop, @stack.pop] # Hm, @stack.pop(2) doesn't work
    @stack.push dividend / divisor
  end
end