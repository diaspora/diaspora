# encoding: utf-8
class HesapMakinesi
  def push(n)
    @args ||= []
    @args << n
  end
  
  def topla
    @args.inject(0){|n,sum| sum+=n}
  end

  def böl
    @args[0].to_f / @args[1].to_f
  end
end