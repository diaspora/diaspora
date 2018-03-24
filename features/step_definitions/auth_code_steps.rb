# frozen_string_literal: true

O_AUTH_QUERY_PARAMS_WITH_CODE = {
  redirect_uri:  "http://example.org/",
  response_type: "code",
  scope:         "openid profile read",
  nonce:         "hello",
  state:         "hi"
}

Given /^I send a post request from that client to the code flow authorization endpoint$/ do
  client_json = JSON.parse(last_response.body)
  @client_id = client_json["client_id"]
  @client_secret = client_json["client_secret"]
  params = O_AUTH_QUERY_PARAMS_WITH_CODE.merge(client_id: @client_id)
  visit new_api_openid_connect_authorization_path(params)
end

Given /^I send a post request from that client to the code flow authorization endpoint using a invalid client id/ do
  params = O_AUTH_QUERY_PARAMS_WITH_CODE.merge(client_id: "randomid")
  visit new_api_openid_connect_authorization_path(params)
end

When /^I parse the auth code and create a request to the token endpoint$/ do
  current_url = page.driver.network_traffic.last.url # We get a redirect to example.org that we can't follow
  code = current_url[/(?<=code=)[^&]+/]
  expect(code).to be_present
  post api_openid_connect_access_tokens_path, code: code,
       redirect_uri: "http://example.org/", grant_type: "authorization_code",
       client_id: @client_id, client_secret: @client_secret
end

When /^I parse the tokens and use it obtain user info$/ do
  client_json = JSON.parse(last_response.body)
  expect(client_json).to_not have_key "error"
  access_token = client_json["access_token"]
  encoded_id_token = client_json["id_token"]
  decoded_token = OpenIDConnect::ResponseObject::IdToken.decode encoded_id_token,
                                                                Api::OpenidConnect::IdTokenConfig::PUBLIC_KEY
  expect(decoded_token.sub).to eq(@me.diaspora_handle)
  get api_openid_connect_user_info_path, access_token: access_token
end
