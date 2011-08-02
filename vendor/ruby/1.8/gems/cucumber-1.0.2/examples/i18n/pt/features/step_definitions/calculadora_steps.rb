# encoding: utf-8

Before do
  @calc = Calculadora.new
end

After do
end

Dado /que eu digitei (\d+) na calculadora/ do |n|
  @calc.push n.to_i
end

Quando 'eu aperto o botão de soma' do
  @result = @calc.soma
end

Então /o resultado na calculadora deve ser (\d*)/ do |result|
  @result.should == result.to_i
end
