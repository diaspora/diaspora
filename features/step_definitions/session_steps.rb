
Given /^(?:I am signed in|I sign in)$/ do
  automatic_login
  confirm_login
end

When /^I try to sign in$/ do
  automatic_login
end

When /^I try to sign in manually$/ do
  manual_login
end

When /^I (?:sign|log) in manually as "([^"]*)" with password "([^"]*)"$/ do |username, password|
  @me = User.find_by_username(username)
  @me.password ||= password
  manual_login
  confirm_login
end

When /^I (?:sign|log) in as "([^"]*)"$/ do |email|
  @me = User.find_by_email(email)
  @me.password ||= 'password'
  automatic_login
  confirm_login
end

When /^I (?:sign|log) in with password "([^"]*)"$/ do |password|
  @me.password = password
  automatic_login
  confirm_login
end

When /^I put in my password in "([^"]*)"$/ do |field|
 step %(I fill in "#{field}" with "#{@me.password}")
end

When /^I (?:log|sign) out$/ do
  logout
end
