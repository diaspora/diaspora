module OAuth2
  class ErrorWithResponse < StandardError; attr_accessor :response end
  class AccessDenied < ErrorWithResponse; end
  class HTTPError < ErrorWithResponse; end
end

require 'oauth2/client'
require 'oauth2/strategy/base'
require 'oauth2/strategy/web_server'
require 'oauth2/access_token'
require 'oauth2/response_object'