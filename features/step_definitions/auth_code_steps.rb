o_auth_query_params = %i(
  redirect_uri=http://localhost:3000
  response_type=code
  scope=openid%20read
  nonce=hello
  state=hi
).join("&")

Given /^I send a post request from that client to the code flow authorization endpoint$/ do
  client_json = JSON.parse(last_response.body)
  @client_id = client_json['o_auth_application']['client_id']
  @client_secret = client_json['o_auth_application']['client_secret']
  visit new_api_openid_connect_authorization_path +
          "?client_id=#{@client_id}&#{o_auth_query_params}"
end

Given /^I send a post request from that client to the code flow authorization endpoint using a invalid client id/ do
  visit new_api_openid_connect_authorization_path + "?client_id=randomid&#{o_auth_query_params}"
end

When /^I parse the auth code and create a request to the token endpoint$/ do
  code = current_url[/(?<=code=)[^&]+/]
  post api_openid_connect_access_tokens_path, code: code,
       redirect_uri: "http://localhost:3000", grant_type: "authorization_code",
       client_id: @client_id, client_secret: @client_secret
end

When /^I parse the tokens and use it obtain user info$/ do
  client_json = JSON.parse(last_response.body)
  access_token = client_json["access_token"]
  get api_openid_connect_user_info_path, access_token: access_token
end
