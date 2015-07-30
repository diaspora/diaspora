Given(/^all scopes exist$/) do
  Api::OpenidConnect::Scope.find_or_create_by(name: "openid")
  Api::OpenidConnect::Scope.find_or_create_by(name: "read")
end

When /^I register a new client$/ do
  post api_openid_connect_clients_path, redirect_uris: ["http://localhost:3000"], client_name: "diaspora client"
end

When /^I use received valid bearer tokens to access user info$/ do
  access_token_json = JSON.parse(last_response.body)
  get api_v0_user_path, access_token: access_token_json["access_token"]
end

When /^I use invalid bearer tokens to access user info$/ do
  get api_v0_user_path, access_token: SecureRandom.hex(32)
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
