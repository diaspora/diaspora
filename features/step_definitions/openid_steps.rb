When /^I register a new client$/ do
  clientRegistrationURL = "/openid_connect/clients"
  post clientRegistrationURL,
       {
         redirect_uris: ["http://localhost:3000"] # Not actually used
       }
end

Given /^I send a post request from that client to the token endpoint using "([^\"]*)"'s credentials$/ do |username|
  clientJSON = JSON.parse(last_response.body)
  user = User.find_by(username: username)
  tokenEndpointURL = "/openid_connect/access_tokens"
  post tokenEndpointURL,
    {
      grant_type: "password",
      username: user.username,
      password: "password", # Password has been hard coded as all test accounts seem to have a password of "password"
      client_id: clientJSON["o_auth_application"]["client_id"],
      client_secret: clientJSON["o_auth_application"]["client_secret"]
    }
end

Given /^I send a post request from that client to the token endpoint using invalid credentials$/ do
  clientJSON = JSON.parse(last_response.body)
  tokenEndpointURL = "/openid_connect/access_tokens"
  post tokenEndpointURL,
       {
         grant_type: "password",
         username: User.find_by(username: "bob"),
         password: "wrongpassword",
         client_id: clientJSON["o_auth_application"]["client_id"],
         client_secret: clientJSON["o_auth_application"]["client_secret"]
       }
end

When /^I use received valid bearer tokens to access user info$/ do
  accessTokenJson = JSON.parse(last_response.body)
  userInfoEndPointURL = "/api/v0/user/"
  get userInfoEndPointURL,
    {
      access_token: accessTokenJson["access_token"]
    }
end

When /^I use invalid bearer tokens to access user info$/ do
  userInfoEndPointURL = "/api/v0/user/"
  get userInfoEndPointURL,
      {
        access_token: SecureRandom.hex(32)
      }
end

Then /^I should receive "([^\"]*)"'s id, username, and email$/ do |username|
  userInfoJson = JSON.parse(last_response.body)
  user = User.find_by_username(username)
  expect(userInfoJson["username"]).to have_content(user.username)
  expect(userInfoJson["language"]).to have_content(user.language)
  expect(userInfoJson["email"]).to have_content(user.email)
end

Then /^I should receive an "([^\"]*)" error$/ do |error_message|
  userInfoJson = JSON.parse(last_response.body)
  expect(userInfoJson["error"]).to have_content(error_message)
end
