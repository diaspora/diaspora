# Password has been hard coded as all test accounts seem to have a password of "password"
Given /^I send a post request to the token endpoint using "([^\"]*)"'s credentials$/ do |username|
  user = User.find_by(username: username)
  tokenEndpointURL = "/openid/access_tokens"
  tokenEndpointURLQuery = "?grant_type=password&username=" +
    user.username +
    "&password=password&client_id=4&client_secret=azerty"
  post tokenEndpointURL + tokenEndpointURLQuery
end

When /^I use received valid bearer tokens to access user info via URI query parameter$/ do
  accessTokenJson = JSON.parse(last_response.body)
  userInfoEndPointURL = "/openid/user_info/"
  userInfoEndPointURLQuery = "?access_token=" + accessTokenJson["access_token"]
  visit userInfoEndPointURL + userInfoEndPointURLQuery
end

When /^I use invalid bearer tokens to access user info via URI query parameter$/ do
  userInfoEndPointURL = "/openid/user_info/"
  userInfoEndPointURLQuery = "?access_token=" + SecureRandom.hex(32)
  visit userInfoEndPointURL + userInfoEndPointURLQuery
end

Then /^I should receive "([^\"]*)"'s id, username, and email$/ do |username|
  user = User.find_by_username(username)
  expect(page).to have_content(user.username)
  expect(page).to have_content(user.language)
  expect(page).to have_content(user.email)
end

Then /^I should receive an "([^\"]*)" error$/ do |error_message|
  expect(page).to have_content(error_message)
end

Then /^I should see "([^\"]*)" in the content$/ do |content|
  expect(page).to have_content(content)
end
