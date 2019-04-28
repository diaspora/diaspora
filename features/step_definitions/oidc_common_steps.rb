# frozen_string_literal: true

Given /^a client with a provided picture exists for user "([^\"]*)"$/ do |email|
  app = FactoryGirl.create(:o_auth_application, logo_uri: "/assets/user/default.png")
  user = User.find_by(email: email)
  FactoryGirl.create(:auth_with_read_scopes, user: user, o_auth_application: app)
end

Given /^a client exists for user "([^\"]*)"$/ do |email|
  user = User.find_by(email: email)
  FactoryGirl.create(:auth_with_read_scopes, user: user)
end

When /^I register a new client$/ do
  post api_openid_connect_clients_path, redirect_uris: ["http://example.org/"], client_name: "diaspora client"
end

When /^I use received valid bearer tokens to access user info$/ do
  access_token_json = JSON.parse(last_response.body)
  get api_openid_connect_user_info_path, access_token: access_token_json["access_token"]
end

When /^I use invalid bearer tokens to access user info$/ do
  get api_openid_connect_user_info_path, access_token: SecureRandom.hex(32)
end

Then /^I should receive "([^\"]*)"'s id, username, and email$/ do |username|
  user_info_json = JSON.parse(last_response.body)
  user = User.find_by_username(username)
  user_profile_url = File.join(AppConfig.environment.url, "people", user.guid).to_s
  expect(user_info_json["profile"]).to have_content(api_v1_user_path)
end

Then /^I should receive an "([^\"]*)" error$/ do |error_message|
  user_info_json = JSON.parse(last_response.body)
  expect(user_info_json["error"]).to have_content(error_message)
end

Then(/^I should see a message containing "(.*?)"$/) do |message|
  expect(find("#openid_connect_error_description").text).to include(message)
end
