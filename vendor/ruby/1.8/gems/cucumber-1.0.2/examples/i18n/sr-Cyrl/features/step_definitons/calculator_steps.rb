# encoding: utf-8

Before do
  @calc = Calculator.new
end

After do
end

Задати /унесен број (\d+) у калкулатор/ do |n|
  @calc.push n.to_i
end

Када /притиснем (\w+)/ do |op|
  @result = @calc.send op
end

Онда /би требало да буде (.*) прикаѕано на екрану/ do |result|
  @result.should == result.to_f
end
