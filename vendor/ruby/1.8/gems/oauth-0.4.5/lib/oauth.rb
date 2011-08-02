$LOAD_PATH << File.dirname(__FILE__) unless $LOAD_PATH.include?(File.dirname(__FILE__))

module OAuth
  VERSION = "0.4.5"
end

require 'oauth/oauth'
require 'oauth/core_ext'

require 'oauth/client/helper'
require 'oauth/signature/hmac/sha1'
require 'oauth/signature/rsa/sha1'
require 'oauth/request_proxy/mock_request'
