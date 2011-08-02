class Belly
  attr_reader :cukes
  
  def initialize
    @cukes = 0
  end
  
  def eat(cukes)
    @cukes += cukes
  end
end