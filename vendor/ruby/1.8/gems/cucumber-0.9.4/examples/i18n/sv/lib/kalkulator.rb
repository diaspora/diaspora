class Kalkulator
  def push(n)
    @args ||= []
    @args << n
  end
  
  def add
    #@args[0] + @args[1]
    @args.inject(0){|n,sum| sum+=n}
  end
end