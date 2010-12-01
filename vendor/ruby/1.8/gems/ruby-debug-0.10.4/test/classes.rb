class Mine
  def initialize
    @myvar = 'init'
  end
  def mymethod(a, b=5, &block)
  end
  def self.classmeth
  end
end
me = Mine.new
metoo = Mine(new)
