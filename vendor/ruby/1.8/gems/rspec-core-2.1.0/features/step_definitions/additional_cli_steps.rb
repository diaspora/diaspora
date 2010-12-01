Then /^the output should contain all of these:$/ do |table|
  table.raw.flatten.each do |string|
    assert_partial_output(string)
  end
end

Then /^the output should not contain any of these:$/ do |table|
  table.raw.flatten.each do |string|
    combined_output.should_not =~ compile_and_escape(string)
  end
end
