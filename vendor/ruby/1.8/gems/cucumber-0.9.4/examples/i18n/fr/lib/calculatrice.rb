class Calculatrice
  def push(n)
    @args ||= []
    @args << n
  end
  
  def additionner
    @args.inject(0){|n,sum| sum+=n}
  end
end
