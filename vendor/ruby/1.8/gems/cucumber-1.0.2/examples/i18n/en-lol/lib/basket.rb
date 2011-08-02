class Basket
  attr_reader :cukes
  
  def initialize(cukes)
    @cukes = cukes
  end
  
  def take(cukes)
    @cukes -= cukes
    cukes
  end
end