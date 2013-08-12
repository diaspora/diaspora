Given /^(?:I am signed in)$/ do
  automatic_login
  confirm_login
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

When /^I fill out change password section with my password and "([^"]*)" and "([^"]*)"$/ do |new_pass, confirm_pass|
  fill_change_password_section(@me.password, new_pass, confirm_pass)
end

When /^I fill out forgot password form with "([^"]*)"$/ do |email|
  fill_forgot_password_form(email)
end

When /^I submit forgot password form$/ do
  submit_forgot_password_form
end

When /^I fill out reset password form with "([^"]*)" and "([^"]*)"$/ do |new_pass,confirm_pass|
  fill_reset_password_form(new_pass, confirm_pass)
end

When /^I submit reset password form$/ do
  submit_reset_password_form
end

When /^I (?:log|sign) out$/ do
  logout
end

When /^I (?:log|sign) out manually$/ do
  manual_logout
end
