# frozen_string_literal: true

Given /^the terms of use are enabled$/ do
  AppConfig.settings.terms.enable = true
end

And /^I should see the report modal/ do
  step %(I should see "You are about to send an email to all " within "#reportModal")
end

And /^I should see a report by "([^\"]*)" with reason "([^\"]*)" on post "([^\"]*)"$/ do |reporter, reason, content|
  step %(I should see "#{reporter}" within ".reporter")
  step %(I should see "#{reason}" within ".reason")
  step %(I should see "Message: #{content}" within ".content")
end

And /^I should see a report by "([^\"]*)" with reason "([^\"]*)" on comment "([^\"]*)"$/ do |reporter, reason, content|
  step %(I should see "#{reporter}" within ".reporter")
  step %(I should see "#{reason}" within ".reason")
  step %(I should see "Comment: #{content}" within ".content")
end
