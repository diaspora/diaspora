# encoding: utf-8
class Calculator
  def push(n)
    @args ||= []
    @args << n
  end
  
  def جمع
    @args.inject(0){|n,sum| sum+=n}
  end
end