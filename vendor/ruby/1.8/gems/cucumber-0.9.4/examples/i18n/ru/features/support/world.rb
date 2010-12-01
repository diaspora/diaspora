# encoding: utf-8
module LazyCalc
  def calc
    @calc ||= Calculator.new
  end
end

World(LazyCalc)
