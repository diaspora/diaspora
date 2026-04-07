# frozen_string_literal: true

Given /^the terms of use are enabled$/ do
  AppConfig.settings.terms.enable = true
end

And /^I should see the report modal/ do
  step %(I should see "Reporting content" within "#reportModal")
end

And /^I should see a report by "([^"]*)" with reason "([^"]*)" on post "([^"]*)" by "([^"]*)"$/ do
  |reporter, reason, content, author|
  test_report("Post", User.find_by(email: reporter), reason, content, author)
end

And /^I should see a report by "([^"]*)" with reason "([^"]*)" on comment "([^"]*)" by "([^"]*)"$/ do
  |reporter, reason, content, author|
  test_report("Comment", User.find_by(email: reporter), reason, content, author)
end

def test_report(type, reporter, reason, content, author)
  step %(I should see "#{reporter.username}" within ".reporter")
  step %(I should see "#{reason}" within ".reason")
  step %(I should see "#{author}:" within ".content")
  step %(I should see "#{type}:" within ".content")
  step %(I should see "#{content}" within ".content")
end
