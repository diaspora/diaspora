Then /^I should see ([1-9]+) options?$/ do |number|
  find("#publisher-poll-creator").all(".poll-answer").count.should eql(number.to_i)
end

And /^I delete the last option$/ do
  find("#publisher-poll-creator").all(".poll-answer .remove-answer").first.click
end

And /^I should not see a remove icon$/ do
  page.should_not have_css(".remove-answer")
end

When /^I fill in the following for the options:$/ do |table|
  i = 0
  table.raw.flatten.each do |value|
    all(".poll-answer input")[i].set(value)
    i+=1
  end
end

When /^I check the first option$/ do
  page.should have_css('.poll_form input')
  first(".poll_form input").click
end

And /^I press the element "([^"]*)"$/ do |selector|
  page.should have_css(selector)
  find(selector).click
end

Then /^I should see an element "([^"]*)"$/ do |selector|
  page.should have_css(selector)
end
