# encoding: utf-8

Дадено /въвел (\d+)/ do |x|
  calc.push x.to_i
end

Когато /^въведа (\d+)/ do |x|
  calc.push x.to_i
end

Когато /натисна "(.*)"/ do |op|
  calc.send op
end

То /резултата трябва да е равен на (\d+)/ do |result|
  calc.result.should == result.to_f
end

Дадено /събрал (\d+) и (\d+)/ do |x, y|
  Дадено %{въвел #{x}}
  Дадено %{въвел #{y}}  
  Дадено %{натисна "+"}
end

