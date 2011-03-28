Given /^I am signed in as the following (\w+):$/ do |role, table|
  Given %(the following #{role}:), table
  @me = @it
  Given 'I am signed in'
end

Given /^I (?:am signed|sign) in as an? (\w+)$/ do |role|
  @me = Factory(role.to_sym)
  Given 'I am signed in'
end

Given /^(?:I am signed in|I sign in)$/ do
  When %(I try to sign in)
  wait_until { page.has_content?(@me.diaspora_handle) }
end

When /^I try to sign in$/ do
  @me ||= Factory(:user_with_aspect, :getting_started => false)
  When %(I go to the new user session page)
  When %(I fill in "Username" with "#{@me.username}")
  When %(I fill in "Password" with "#{@me.password}")
  When %(I press "Sign in")
end

When /^I sign in as "([^"]*)"$/ do |email|
  @me = User.find_by_email(email)
  @me.password ||= 'password'
  Given 'I am signed in'
end

When /^I sign in with password "([^"]*)"$/ do |password|
  @me.password = password
  Given 'I am signed in'
end

When /^I put in my password in "([^"]*)"$/ do |field|
 When %(I fill in "#{field}" with "#{@me.password}")
end

When /^I (?:log|sign) out$/ do
  When 'I click on my name in the header'
  And 'I follow "logout"'
end
