Given /^I have signed up on the web$/ do
  # just pretend we do
end

When /^I check my mailbox$/ do
  @answer = ask("What's in your mailbox? ", 3)
end

Then /^I should have an email containing "([^"]*)"$/ do |content|
  @answer.should =~ Regexp.new(content)
end
