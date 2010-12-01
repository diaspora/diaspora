When /^I ask Tcl to calculate fibonacci for (\d+)$/ do |n|
  @fib_result = @fib.eval("fib #{n}").to_i
end

Then /^it should give me (\d+)$/ do |expected|
  @fib_result.should == expected.to_i
end
