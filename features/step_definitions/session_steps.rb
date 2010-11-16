Given /^I am signed in as the following (\w+):$/ do |role, table|
  Given %(the following #{role}:), table
  @me = @it
  Given 'I am signed in'
end

Given /^I (?:am signed|sign) in as an? (\w+)$/ do |role|
  @me = Factory(role.to_sym)
  Given 'I am signed in'
end


Given 'I am signed in' do
  @me ||= Factory(:user, :getting_started => false)
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
