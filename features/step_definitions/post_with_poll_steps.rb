# frozen_string_literal: true

Then /^I should see ([1-9]+) options?$/ do |number|
  find("#poll_creator_container").all(".poll-answer").count.should eql(number.to_i)
end

And /^I delete the last option$/ do
  find("#poll_creator_container").all(".poll-answer .remove-answer").first.click
end

And /^I should not see a remove icon$/ do
  page.should_not have_css(".remove-answer")
end

When /^I fill in the following for the options:$/ do |table|
  i = 0
  table.raw.flatten.each do |value|
    all(".poll-answer input")[i].native.send_keys(value)
    i+=1
  end
end

When /^I check the first option$/ do
  page.should have_css(".poll-form input")
  first(".poll-form input").click
end

When(/^I fill in values for the first two options$/) do
  all(".poll-answer input").each_with_index do |answer, i|
    answer.native.send_keys "answer option #{i}"
  end
end

When(/^I lose focus$/) do
  find("#poll_creator_container").click
end

Then /^I should see an element "([^"]*)"$/ do |selector|
  page.should have_css(selector)
end
