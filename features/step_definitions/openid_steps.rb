When /^I register a new client$/ do
  client_registration_url = "/openid_connect/clients"
  post client_registration_url, redirect_uris: ["http://localhost:3000"] # Not actually used
end

Given /^I send a post request from that client to the token endpoint using "([^\"]*)"'s credentials$/ do |username|
  client_json = JSON.parse(last_response.body)
  user = User.find_by(username: username)
  token_endpoint_url = "/openid_connect/access_tokens"
  post token_endpoint_url, grant_type: "password", username: user.username,
      password: "password", # Password has been hard coded as all test accounts seem to have a password of "password"
      client_id: client_json["o_auth_application"]["client_id"],
      client_secret: client_json["o_auth_application"]["client_secret"]
end

Given /^I send a post request from that client to the token endpoint using invalid credentials$/ do
  client_json = JSON.parse(last_response.body)
  token_endpoint_url = "/openid_connect/access_tokens"
  post token_endpoint_url, grant_type: "password", username: "bob", password: "wrongpassword",
         client_id: client_json["o_auth_application"]["client_id"],
         client_secret: client_json["o_auth_application"]["client_secret"]
end

When /^I use received valid bearer tokens to access user info$/ do
  access_token_json = JSON.parse(last_response.body)
  user_info_endpoint_url = "/api/v0/user/"
  get user_info_endpoint_url, access_token: access_token_json["access_token"]
end

When /^I use invalid bearer tokens to access user info$/ do
  user_info_endpoint_url = "/api/v0/user/"
  get user_info_endpoint_url, access_token: SecureRandom.hex(32)
end

Then /^I should receive "([^\"]*)"'s id, username, and email$/ do |username|
  user_info_json = JSON.parse(last_response.body)
  user = User.find_by_username(username)
  expect(user_info_json["username"]).to have_content(user.username)
  expect(user_info_json["language"]).to have_content(user.language)
  expect(user_info_json["email"]).to have_content(user.email)
end

Then /^I should receive an "([^\"]*)" error$/ do |error_message|
  user_info_json = JSON.parse(last_response.body)
  expect(user_info_json["error"]).to have_content(error_message)
end
