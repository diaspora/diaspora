Given /a remote service that returns '(.*)'/ do |response_body|
  @handler = BasicMongrelHandler.new
  Given "the response from the service has a body of '#{response_body}'"
end

Given /a remote service that returns a (\d+) status code/ do |code|
  @handler = BasicMongrelHandler.new
  @handler.response_code = code
end

Given /that service is accessed at the path '(.*)'/ do |path|
  @server.register(path, @handler)
end

Given /^that service takes (\d+) seconds to generate a response$/ do |time|
  @server_response_time = time.to_i
  @handler.preprocessor = lambda { sleep time.to_i }
end

Given /^a remote deflate service$/ do
  @handler = DeflateHandler.new
end

Given /^a remote gzip service$/ do
  @handler = GzipHandler.new
end

Given /the response from the service has a Content-Type of '(.*)'/ do |content_type|
  @handler.content_type = content_type
end

Given /the response from the service has a body of '(.*)'/ do |response_body|
  @handler.response_body = response_body
end

Given /the url '(.*)' redirects to '(.*)'/ do |redirection_url, target_url|
  @server.register redirection_url, new_mongrel_redirector(target_url)
end

Given /that service is protected by Basic Authentication/ do
  @handler.extend BasicAuthentication
end

Given /that service is protected by Digest Authentication/ do
  @handler.extend DigestAuthentication
end

Given /that service requires the username '(.*)' with the password '(.*)'/ do |username, password|
  @handler.username = username
  @handler.password = password
end

Given /a restricted page at '(.*)'/ do |url|
  Given "a remote service that returns 'A response I will never see'"
  And "that service is accessed at the path '#{url}'"
  And "that service is protected by Basic Authentication"
  And "that service requires the username 'something' with the password 'secret'"
end

# This joins the server thread, and halts cucumber, so you can actually hit the
# server with a browser.  Runs until you kill it with Ctrl-c
Given /I want to hit this in a browser/ do
  @server.acceptor.join
end

Then /I wait for the server to recover/ do
  timeout = @request_options[:timeout] || 0
  sleep @server_response_time - timeout
end
