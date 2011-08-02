require 'benchmark'

def hash(options)
  result = "#{options.delete(:name)}"
  for key, value in options
    result << " #{key} => #{value} "
  end
  result
end

def optional(name, a = nil, b = nil, c = nil)
  result = "#{name}"
  options = { :a => a, :b => b, :c => c }
  for key, value in options
    result << " #{key} => #{value} "
  end
  result
end

COUNT = 100_000
data = "Content-Length: 100"
Benchmark.bmbm(25) do |bench|
  bench.report('hash') do
    COUNT.times do
      hash({:name => 'name'})
    end
  end
  bench.report('optional') do
    COUNT.times do
      optional('name')
    end
  end
  bench.report('hash_with_option') do
    COUNT.times do
      hash({:name => 'name', :a => 'a', :b => 'b', :c => 'c'})
    end
  end
  bench.report('optional_with_option') do
    COUNT.times do
      optional('name', :a => 'a', :b => 'b', :c => 'c')
    end
  end
end
