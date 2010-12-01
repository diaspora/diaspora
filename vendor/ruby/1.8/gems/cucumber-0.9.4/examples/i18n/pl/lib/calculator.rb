class Calculator
  def push(n)
    @args ||= []
    @args << n
  end
  
  def dodaj
    @args.inject(0){|n,sum| sum+=n}
  end

  def podziel
    @args[0].to_f / @args[1].to_f
  end
end