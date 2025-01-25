# frozen_string_literal: true

Given /^the terms of use are enabled$/ do
  AppConfig.settings.terms.enable = true
end

And /^I should see the report modal/ do
  step %(I should see "Reporting content" within "#reportModal")
end

And /^I should see a report by "([^"]*)" with reason "([^"]*)" on post "([^"]*)"$/ do |reporter, reason, content|
  test_report("Post", User.find_by(email: reporter), reason, content)
end

And /^I should see a report by "([^"]*)" with reason "([^"]*)" on comment "([^"]*)"$/ do |reporter, reason, content|
  test_report("Comment", User.find_by(email: reporter), reason, content)
end

def test_report(type, reporter, reason, content)
  step %(I should see "#{reporter.username}" within ".reporter")
  step %(I should see "#{reason}" within ".reason")
  step %(I should see "#{type}: #{content}" within ".content")
end

And(/^I mark report as reviewed$/) do
  click_button("Mark as reviewed")
end

And(/^I mark report as deleted$/) do
  click_button("Delete item")
end

And(/^I delete the reviewed report$/) do
  find_link(title: "Delete item").click
end

When(/^I open the reviewed tab on the report page$/) do
  find_link("Reviewed").click
end

Then(/^I should see the reviewed report with decision "([^"]*)"$/) do |decision|
  within("#checked") do
    find("tr", text: decision)
  end
end
