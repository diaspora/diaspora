def create_beta_user(opts)
  user = create_user(opts)
  Role.add_beta(user.person)
  user
end

Given /^I am logged in as a beta user with email "(.*?)"$/ do |email|
  @me = create_beta_user(:email => email, :password => 'password', :password_confirmation => 'password')
  visit login_page
  login_as(@me.username, 'password')
end

Given /^a beta user "(.*?)"$/ do |email|
  create_beta_user(:email => email)
end

When /^"([^"]*)" is an admin$/ do |email|
  Role.add_admin(User.find_by_email(email).person)
end