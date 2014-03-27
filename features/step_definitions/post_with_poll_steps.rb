Then /^I should see ([1-9]+) options?$/ do |number|
  find("#poll_creator_wrapper").all(".poll_answer").count.should eql(number.to_i)
end

And /^I delete the first option$/ do
  find("#poll_creator_wrapper").all(".poll_answer .remove_poll_answer").first.click
end

And /^I should not see a remove icon$/ do
  page.should_not have_css(".remove_poll_answer")
end

When /^I fill in the following for the options:$/ do |table|
  i = 0
  table.raw.flatten.each do |value|
    all(".poll_answer_input")[i].set(value)
    i+=1
  end
end

When /^I check the first option$/ do
  sleep 1
  first(".poll_form input").click
end

And /^I press the element "([^"]*)"$/ do |selector|
  find(selector).click
end

Then /^I should see an element "([^"]*)"$/ do |selector|
  page.should have_css(selector)
end