class Calculadora
  def push(n)
    @args ||= []
    @args << n
  end
  
  def soma
    @args.inject(0) {|n,sum| sum+n}
  end
end
