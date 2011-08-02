When /^I ask python to calculate fibonacci up to (\d+)$/ do |n|
  @fib_result = @fib.fib(n.to_i)
end

Then /^it should give me (\[.*\])$/ do |expected|
  @fib_result.inspect.should == expected
end
