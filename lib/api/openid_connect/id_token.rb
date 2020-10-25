# frozen_string_literal: true

# Copyright (c) 2011 nov matake
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# See https://github.com/nov/openid_connect_sample/blob/master/app/models/id_token.rb

require "uri"

module Api
  module OpenidConnect
    class IdToken
      def initialize(authorization, nonce)
        @authorization = authorization
        @nonce = nonce
        @created_at = Time.current
        @expires_at = 30.minutes.from_now
      end

      def to_jwt(options={})
        to_response_object(options).to_jwt(OpenidConnect::IdTokenConfig::PRIVATE_KEY) do |jwt|
          jwt.kid = :default
        end
      end

      private

      def to_response_object(options={})
        OpenIDConnect::ResponseObject::IdToken.new(claims).tap do |id_token|
          id_token.code = options[:code] if options[:code]
          id_token.access_token = options[:access_token] if options[:access_token]
        end
      end

      def claims
        sub = build_sub
        @claims ||= {
          iss:       AppConfig.environment.url,
          sub:       sub,
          aud:       @authorization.o_auth_application.client_id,
          exp:       @expires_at.to_i,
          iat:       @created_at.to_i,
          auth_time: @authorization.user.current_sign_in_at.to_i,
          nonce:     @nonce,
          acr:       0
        }
      end

      def build_sub
        Api::OpenidConnect::SubjectIdentifierCreator.create(@authorization)
      end
    end
  end
end
