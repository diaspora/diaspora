require 'webmock'
require 'webmock/rspec/matchers'

World(WebMock::API, WebMock::Matchers)

After do
  WebMock.reset!
end