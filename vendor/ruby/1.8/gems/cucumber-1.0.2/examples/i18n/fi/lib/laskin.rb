class Laskin
  def pinoa(n)
    @args ||= []
    @args << n
  end

  def summaa
    @args.inject(0){|n,sum| sum+=n}
  end

  def jaa
    @args[0].to_f / @args[1].to_f
  end
end
