Given /a passing step/ do
  #does nothing
end

Given /a failing step/ do
  fail
end

Given /a pending step/ do
  pending
end

Given /^I add (\d+) and (\d+)$/ do |a,b|
  @result = a.to_i + b.to_i
end

Then /^I the result should be (\d+)$/ do |c|
  @result.should == c.to_i
end

Then /^I should see/ do |string|

end

Given /^I pass a table argument/ do |table|

end

Given /^I embed a screenshot/ do
  File.open("tmp/screenshot.png", "w") { |file| file << "foo" }
  embed "tmp/screenshot.png", "image/png"
end