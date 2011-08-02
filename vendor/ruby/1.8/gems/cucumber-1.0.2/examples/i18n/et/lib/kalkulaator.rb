class Kalkulaator
  def push(n)
    @args ||= []
    @args << n
  end
  
  def liida
    @args.inject(0){|n,sum| sum+=n}
  end

  def jaga
    @args[0].to_f / @args[1].to_f
  end  
end
