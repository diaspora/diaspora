o_auth_query_params = %i(
  redirect_uri=http://localhost:3000
  response_type=id_token token
  scope=openid
  nonce=hello
  state=hi
).join("&")

Given(/^the OpenID scope exists$/) do
  OpenidConnect::Scope.create(name: "openid")
end

Given /^I send a post request from that client to the implicit flow authorization endpoint$/ do
  client_json = JSON.parse(last_response.body)
  auth_endpoint_url = "/openid_connect/authorizations/new"
  visit "#{auth_endpoint_url}?client_id=#{client_json["o_auth_application"]["client_id"]}&#{o_auth_query_params}"
end

Given /^I send a post request from that client to the implicit flow authorization endpoint using a invalid client id/ do
  auth_endpoint_url = "/openid_connect/authorizations/new"
  visit "#{auth_endpoint_url}?client_id=randomid&#{o_auth_query_params}"
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
  user_info_endpoint_url = "/api/v0/user/"
  get user_info_endpoint_url, access_token: access_token
end

Then /^I should see an "([^\"]*)" error$/ do |error_message|
  expect(page).to have_content(error_message)
end
