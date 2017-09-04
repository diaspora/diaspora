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

# See https://github.com/nov/openid_connect_sample/blob/master/app/models/client.rb

require "digest"

module Api
  module OpenidConnect
    class OAuthApplication < ApplicationRecord
      has_many :authorizations, dependent: :destroy
      has_many :user, through: :authorizations

      validates :client_id, presence: true, uniqueness: true
      validates :client_secret, presence: true
      validates :client_name, uniqueness: {scope: :redirect_uris}

      %i(redirect_uris response_types grant_types contacts jwks).each do |serializable|
        serialize serializable, JSON
      end

      before_validation :setup, on: :create
      before_validation do
        redirect_uris.sort!
      end

      def setup
        self.client_id = SecureRandom.hex(16)
        self.client_secret = SecureRandom.hex(32)
      end

      def image_uri
        logo_uri ? Diaspora::Camo.image_url(logo_uri) : nil
      end

      class << self
        def available_response_types
          ["id_token", "id_token token", "code"]
        end

        def register!(registrar)
          registrar.validate!
          build_client_application(registrar)
        end

        private

        def build_client_application(registrar)
          attributes = registrar_attributes(registrar)
          check_sector_identifier_uri(attributes)
          check_redirect_uris(attributes)
          create! attributes
        end

        def check_sector_identifier_uri(attributes)
          sector_identifier_uri = attributes[:sector_identifier_uri]
          return unless sector_identifier_uri
          response = Faraday.get(sector_identifier_uri)
          sector_identifier_uri_json = JSON.parse(response.body)
          redirect_uris = attributes[:redirect_uris]
          sector_identifier_uri_includes_redirect_uris = (redirect_uris - sector_identifier_uri_json).empty?
          return if sector_identifier_uri_includes_redirect_uris
          raise Api::OpenidConnect::Error::InvalidSectorIdentifierUri.new
        end

        def check_redirect_uris(attributes)
          redirect_uris = attributes[:redirect_uris]
          uri_array = redirect_uris.map {|uri| URI(uri) }
          any_uri_contains_fragment = uri_array.any? {|uri| !uri.fragment.nil? }
          return unless any_uri_contains_fragment
          raise Api::OpenidConnect::Error::InvalidRedirectUri.new
        end

        def supported_metadata
          %i(client_name response_types grant_types application_type
             contacts logo_uri client_uri policy_uri tos_uri redirect_uris
             sector_identifier_uri subject_type token_endpoint_auth_method jwks jwks_uri)
        end

        def registrar_attributes(registrar)
          supported_metadata.each_with_object({}) do |key, attr|
            value = registrar.public_send(key)
            next unless value
            case key
            when :subject_type
              attr[:ppid] = (value == "pairwise")
            when :jwks_uri
              response = Faraday.get(value)
              attr[:jwks] = response.body
              attr[:jwks_uri] = value
            when :jwks
              attr[:jwks] = value.to_json
            else
              attr[key] = value
            end
          end
        end
      end
    end
  end
end
