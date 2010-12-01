#
# Author:: Christopher Brown (<cb@opscode.com>)
# Author:: Christopher Walters (<cw@opscode.com>)
# Copyright:: Copyright (c) 2009, 2010 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'time'
require 'base64'
require 'digest/sha1'
require 'mixlib/authentication'
require 'mixlib/authentication/digester'

module Mixlib
  module Authentication

    module SignedHeaderAuth
      
      SIGNING_DESCRIPTION = 'version=1.0'

      # This is a module meant to be mixed in but can be used standalone
      # with the simple OpenStruct extended with the auth functions
      class << self
        def signing_object(args={ })
          SigningObject.new(args[:http_method], args[:path], args[:body], args[:host], args[:timestamp], args[:user_id], args[:file])
        end
      end

      # Build the canonicalized request based on the method, other headers, etc.
      # compute the signature from the request, using the looked-up user secret
      # ====Parameters
      # private_key<OpenSSL::PKey::RSA>:: user's RSA private key.
      def sign(private_key)
        # Our multiline hash for authorization will be encoded in multiple header
        # lines - X-Ops-Authorization-1, ... (starts at 1, not 0!)
        header_hash = {
          "X-Ops-Sign" => SIGNING_DESCRIPTION,
          "X-Ops-Userid" => user_id,
          "X-Ops-Timestamp" => canonical_time,
          "X-Ops-Content-Hash" => hashed_body,
        }

        string_to_sign = canonicalize_request
        signature = Base64.encode64(private_key.private_encrypt(string_to_sign)).chomp
        signature_lines = signature.split(/\n/)
        signature_lines.each_index do |idx|
          key = "X-Ops-Authorization-#{idx + 1}"
          header_hash[key] = signature_lines[idx]
        end
        
        Mixlib::Authentication::Log.debug "String to sign: '#{string_to_sign}'\nHeader hash: #{header_hash.inspect}"
        
        header_hash
      end
      
      # Build the canonicalized time based on utc & iso8601
      # 
      # ====Parameters
      # 
      def canonical_time
        Time.parse(timestamp).utc.iso8601
      end
      
      # Build the canonicalized path, which collapses multiple slashes (/) and
      # removes a trailing slash unless the path is only "/"
      # 
      # ====Parameters
      # 
      def canonical_path
        p = path.gsub(/\/+/,'/')
        p.length > 1 ? p.chomp('/') : p
      end
      
      def hashed_body
        # Hash the file object if it was passed in, otherwise hash based on
        # the body.
        # TODO: tim 2009-12-28: It'd be nice to just remove this special case,
        # always sign the entire request body, using the expanded multipart
        # body in the case of a file being include.
        @hashed_body ||= (self.file && self.file.respond_to?(:read)) ? digester.hash_file(self.file) : digester.hash_string(self.body)
      end
      
      # Takes HTTP request method & headers and creates a canonical form
      # to create the signature
      # 
      # ====Parameters
      # 
      # 
      def canonicalize_request
        "Method:#{http_method.to_s.upcase}\nHashed Path:#{digester.hash_string(canonical_path)}\nX-Ops-Content-Hash:#{hashed_body}\nX-Ops-Timestamp:#{canonical_time}\nX-Ops-UserId:#{user_id}"
      end
      
      # Parses signature version information, algorithm used, etc.
      #
      # ====Parameters
      #
      def parse_signing_description
        parts = signing_description.strip.split(";").inject({ }) do |memo, part|
          field_name, field_value = part.split("=")
          memo[field_name.to_sym] = field_value.strip
          memo
        end
        Mixlib::Authentication::Log.debug "Parsed signing description: #{parts.inspect}"
      end
      
      def digester
        Mixlib::Authentication::Digester
      end
      
      private :canonical_time, :canonical_path, :parse_signing_description, :digester
      
    end

    class SigningObject < Struct.new(:http_method, :path, :body, :host, :timestamp, :user_id, :file)
      include SignedHeaderAuth
    end

  end
end
