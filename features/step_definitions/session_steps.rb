Given /^(?:I am signed in|I sign in)$/ do
  step %(I try to sign in)
  wait_until { page.has_content?("#{@me.first_name} #{@me.last_name}") }
end

When /^I try to sign in$/ do
  @me ||= Factory(:user_with_aspect, :getting_started => false)
  page.driver.visit(new_integration_sessions_path(:user_id => @me.id))
  step %(I press "Login")
  # To save time as compared to:
  #step %(I go to the new user session page)
  #step %(I fill in "Username" with "#{@me.username}")
  #step %(I fill in "Password" with "#{@me.password}")
  #step %(I press "Sign in")
end

When /^I try to sign in manually$/ do
  visit login_page
  login_as @me.username, @me.password
end

When /^I (?:sign|log) in manually as "([^"]*)" with password "([^"]*)"$/ do |username, password|
  visit login_page
  login_as username, password
end

When /^I (?:sign|log) in as "([^"]*)"$/ do |email|
  @me = User.find_by_email(email)
  @me.password ||= 'password'
  step 'I am signed in'
end

When /^I (?:sign|log) in with password "([^"]*)"$/ do |password|
  @me.password = password
  step 'I am signed in'
end

When /^I put in my password in "([^"]*)"$/ do |field|
 step %(I fill in "#{field}" with "#{@me.password}")
end

When /^I (?:log|sign) out$/ do
  $browser.delete_cookie('_session', 'path=/') if $browser
  $browser.delete_all_visible_cookies if $browser
end
