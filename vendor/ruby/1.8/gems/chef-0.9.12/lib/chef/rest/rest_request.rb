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
require 'uri'
require 'net/http'
require 'chef/rest/cookie_jar'
require 'chef/version'

class Chef
  class REST
    class RESTRequest
      attr_reader :method, :url, :headers, :http_client, :http_request

      def initialize(method, url, req_body, base_headers={})
        @method, @url = method, url
        @request_body = nil
        @cookies = CookieJar.instance
        configure_http_client
        build_headers(base_headers)
        configure_http_request(req_body)
      end

      def host
        @url.host
      end

      def port
        @url.port
      end

      def query
        @url.query
      end

      def path
        @url.path.empty? ? "/" : @url.path
      end

      def call
        hide_net_http_bug do
          http_client.request(http_request) do |response|
            store_cookie(response)
            yield response if block_given?
            response
          end
        end
      end

      def config
        Chef::Config
      end

      private

      def hide_net_http_bug
        yield
      rescue NoMethodError => e
        # http://redmine.ruby-lang.org/issues/show/2708
        # http://redmine.ruby-lang.org/issues/show/2758
        if e.to_s =~ /#{Regexp.escape(%q|undefined method `closed?' for nil:NilClass|)}/
          Chef::Log.debug("rescued error in http connect, re-raising as Errno::ECONNREFUSED to hide bug in net/http")
          Chef::Log.debug("#{e.class.name}: #{e.to_s}")
          Chef::Log.debug(e.backtrace.join("\n"))
          raise Errno::ECONNREFUSED, "Connection refused attempting to contact #{url.scheme}://#{host}:#{port}"
        else
          raise
        end
      end

      def store_cookie(response)
        if response['set-cookie']
          @cookies["#{host}:#{port}"] = response['set-cookie']
        end
      end

      def build_headers(headers)
        @headers = headers.dup
        # TODO: need to set accept somewhere else
        # headers.merge!('Accept' => "application/json") unless raw
        @headers['X-Chef-Version'] = ::Chef::VERSION

        if @cookies.has_key?("#{host}:#{port}")
          @headers['Cookie'] = @cookies["#{host}:#{port}"]
        end
      end

      #adapted from buildr/lib/buildr/core/transports.rb
      def proxy_uri
        proxy = Chef::Config["#{url.scheme}_proxy"]
        proxy = URI.parse(proxy) if String === proxy
        excludes = Chef::Config[:no_proxy].to_s.split(/\s*,\s*/).compact
        excludes = excludes.map { |exclude| exclude =~ /:\d+$/ ? exclude : "#{exclude}:*" }
        return proxy unless excludes.any? { |exclude| File.fnmatch(exclude, "#{host}:#{port}") }
      end

      def configure_http_client
        http_proxy = proxy_uri
        if http_proxy.nil?
          @http_client = Net::HTTP.new(host, port)
        else
          Chef::Log.debug("using #{http_proxy.host}:#{http_proxy.port} for proxy")
          user = Chef::Config["#{url.scheme}_proxy_user"]
          pass = Chef::Config["#{url.scheme}_proxy_pass"]
          @http_client = Net::HTTP.Proxy(http_proxy.host, http_proxy.port, user, pass).new(host, port)
        end
        if url.scheme == "https"
          @http_client.use_ssl = true
          if config[:ssl_verify_mode] == :verify_none
            @http_client.verify_mode = OpenSSL::SSL::VERIFY_NONE
          elsif config[:ssl_verify_mode] == :verify_peer
            @http_client.verify_mode = OpenSSL::SSL::VERIFY_PEER
          end
          if config[:ssl_ca_path]
            unless ::File.exist?(config[:ssl_ca_path])
              raise Chef::Exceptions::ConfigurationError, "The configured ssl_ca_path #{config[:ssl_ca_path]} does not exist"
            end
            @http_client.ca_path = config[:ssl_ca_path]
          elsif config[:ssl_ca_file]
            unless ::File.exist?(config[:ssl_ca_file])
              raise Chef::Exceptions::ConfigurationError, "The configured ssl_ca_file #{config[:ssl_ca_file]} does not exist"
            end
            @http_client.ca_file = config[:ssl_ca_file]
          end
          if (config[:ssl_client_cert] || config[:ssl_client_key])
            unless (config[:ssl_client_cert] && config[:ssl_client_key])
              raise Chef::Exceptions::ConfigurationError, "You must configure ssl_client_cert and ssl_client_key together"
            end
            unless ::File.exists?(config[:ssl_client_cert])
              raise Chef::Exceptions::ConfigurationError, "The configured ssl_client_cert #{config[:ssl_client_cert]} does not exist"
            end
            unless ::File.exists?(config[:ssl_client_key])
              raise Chef::Exceptions::ConfigurationError, "The configured ssl_client_key #{config[:ssl_client_key]} does not exist"
            end
            @http_client.cert = OpenSSL::X509::Certificate.new(::File.read(config[:ssl_client_cert]))
            @http_client.key = OpenSSL::PKey::RSA.new(::File.read(config[:ssl_client_key]))
          end
        end

        @http_client.read_timeout = config[:rest_timeout]
      end


      def configure_http_request(request_body=nil)
        req_path = "#{path}"
        req_path << "?#{query}" if query

        @http_request = case method.to_s.downcase
        when "get"
          Net::HTTP::Get.new(req_path, headers)
        when "post"
          Net::HTTP::Post.new(req_path, headers)
        when "put"
          Net::HTTP::Put.new(req_path, headers)
        when "delete"
          Net::HTTP::Delete.new(req_path, headers)
        when "head"
          Net::HTTP::Head.new(req_path, headers)
        else
          raise ArgumentError, "You must provide :GET, :PUT, :POST, :DELETE or :HEAD as the method"
        end

        @http_request.body = request_body if (request_body && @http_request.request_body_permitted?)
        # Optionally handle HTTP Basic Authentication
        @http_request.basic_auth(url.user, url.password) if url.user
      end

    end
  end
end
