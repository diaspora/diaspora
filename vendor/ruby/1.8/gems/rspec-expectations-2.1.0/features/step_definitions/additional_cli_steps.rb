# Useful for when the output is slightly different on different versions of ruby
Then /^the output should contain "([^"]*)" or "([^"]*)"$/ do |string1, string2|
  unless [string1, string2].any? { |s| combined_output =~ Regexp.compile(s) }
    fail %Q{Neither "#{string1}" or "#{string2}" were found in:\n#{combined_output}}
  end
end

Then /^the output should contain all of these:$/ do |table|
  table.raw.flatten.each do |string|
    assert_partial_output(string)
  end
end

