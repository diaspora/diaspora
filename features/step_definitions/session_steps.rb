Given /^(?:I am signed in|I sign in)$/ do
  step %(I try to sign in)
  wait_until { page.has_content?("#{@me.first_name} #{@me.last_name}") }
end

When /^I try to sign in$/ do
  @me ||= Factory(:user_with_aspect, :getting_started => false)
  page.driver.visit(new_integration_sessions_path(:user_id => @me.id))
  step %(I press "Login")
  step %(I am on the homepage)
  # To save time as compared to:
  #step %(I go to the new user session page)
  #step %(I fill in "Username" with "#{@me.username}")
  #step %(I fill in "Password" with "#{@me.password}")
  #step %(I press "Sign in")
end

When /^I try to sign in manually$/ do
  step %(I go to the new user session page)
  step %(I fill in "Username" with "#{@me.username}")
  step %(I fill in "Password" with "#{@me.password}")
  step %(I press "Sign in")
end

When /^I sign in as "([^"]*)"$/ do |email|
  @me = User.find_by_email(email)
  @me.password ||= 'password'
  step 'I am signed in'
end

When /^I sign in with password "([^"]*)"$/ do |password|
  @me.password = password
  step 'I am signed in'
end

When /^I put in my password in "([^"]*)"$/ do |field|
 step %(I fill in "#{field}" with "#{@me.password}")
end

When /^I (?:log|sign) out$/ do
  step 'I click on my name in the header'
  step 'I follow "Log out"'
end
