#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Thom May (<thom@clearairturbulence.org>)
# Author:: Nuo Yan (<nuo@opscode.com>)
# Author:: Christopher Brown (<cb@opscode.com>)
# Author:: Christopher Walters (<cw@opscode.com>)
# Author:: Daniel DeLeo (<dan@opscode.com>)
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
require 'chef/exceptions'
require 'mixlib/authentication/signedheaderauth'

class Chef
  class REST
    class AuthCredentials
      attr_reader :key_file, :client_name, :key, :raw_key

      def initialize(client_name=nil, key_file=nil)
        @client_name, @key_file = client_name, key_file
        load_signing_key if sign_requests?
      end

      def sign_requests?
        !!key_file
      end

      def signature_headers(request_params={})
        raise ArgumentError, "Cannot sign the request without a client name, check that :node_name is assigned" if client_name.nil?
        Chef::Log.debug("Signing the request as #{client_name}")

        # params_in = {:http_method => :GET, :path => "/clients", :body => "", :host => "localhost"}
        request_params             = request_params.dup
        request_params[:timestamp] = Time.now.utc.iso8601
        request_params[:user_id]   = client_name
        host = request_params.delete(:host) || "localhost"

        sign_obj = Mixlib::Authentication::SignedHeaderAuth.signing_object(request_params)
        signed =  sign_obj.sign(key).merge({:host => host})
        signed.inject({}){|memo, kv| memo["#{kv[0].to_s.upcase}"] = kv[1];memo}
      end

      private

      def load_signing_key
        begin
          @raw_key = IO.read(key_file).strip
        rescue SystemCallError, IOError => e
          Chef::Log.fatal "Failed to read the private key #{key_file}: #{e.inspect}, #{e.backtrace}"
          raise Chef::Exceptions::PrivateKeyMissing, "I cannot read #{key_file}, which you told me to use to sign requests!"
        end
        assert_valid_key_format!(@raw_key)
        @key = OpenSSL::PKey::RSA.new(@raw_key)
      end

      def assert_valid_key_format!(raw_key)
        unless (raw_key =~ /\A-----BEGIN RSA PRIVATE KEY-----$/) && (raw_key =~ /^-----END RSA PRIVATE KEY-----\Z/)
          msg = "The file #{key_file} does not contain a correctly formatted private key.\n"
          msg << "The key file should begin with '-----BEGIN RSA PRIVATE KEY-----' and end with '-----END RSA PRIVATE KEY-----'"
          raise Chef::Exceptions::InvalidPrivateKey, msg
        end
      end

    end
  end
end
