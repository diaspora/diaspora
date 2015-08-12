O_AUTH_QUERY_PARAMS = {
  redirect_uri:  "http://localhost:3000",
  response_type: "id_token token",
  scope:         "openid read",
  nonce:         "hello",
  state:         "hi",
  prompt:        "login"
}

O_AUTH_QUERY_PARAMS_WITH_MAX_AGE = {
  redirect_uri:  "http://localhost:3000",
  response_type: "id_token token",
  scope:         "openid read",
  nonce:         "hello",
  state:         "hi",
  prompt:        "login",
  max_age:       30
}

Given /^I send a post request from that client to the authorization endpoint$/ do
  client_json = JSON.parse(last_response.body)
  visit new_api_openid_connect_authorization_path(O_AUTH_QUERY_PARAMS.merge(client_id: client_json["client_id"]))
end

Given /^I have signed in (\d+) minutes ago$/ do |minutes|
  @me.update_attribute(:current_sign_in_at, Time.zone.now - minutes.to_i.minute)
end

Given /^I send a post request from that client to the authorization endpoint with max age$/ do
  client_json = JSON.parse(last_response.body)
  visit new_api_openid_connect_authorization_path(
    O_AUTH_QUERY_PARAMS_WITH_MAX_AGE.merge(client_id: client_json["client_id"]))
end

Given /^I send a post request from that client to the authorization endpoint using a invalid client id$/ do
  visit new_api_openid_connect_authorization_path(O_AUTH_QUERY_PARAMS.merge(client_id: "randomid"))
end

When /^I give my consent and authorize the client$/ do
  click_button "Approve"
end

When /^I deny authorization to the client$/ do
  click_button "Deny"
end

Then /^I should not see any tokens in the redirect url$/ do
  access_token = current_url[/(?<=access_token=)[^&]+/]
  id_token = current_url[/(?<=access_token=)[^&]+/]
  expect(access_token).to eq(nil)
  expect(id_token).to eq(nil)
end

When /^I parse the bearer tokens and use it to access user info$/ do
  access_token = current_url[/(?<=access_token=)[^&]+/]
  get api_openid_connect_user_info_path, access_token: access_token
end

Then /^I should see an "([^\"]*)" error$/ do |error_message|
  expect(page).to have_content(error_message)
end
