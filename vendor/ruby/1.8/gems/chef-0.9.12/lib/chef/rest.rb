#--
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Thom May (<thom@clearairturbulence.org>)
# Author:: Nuo Yan (<nuo@opscode.com>)
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

require 'net/https'
require 'uri'
require 'json'
require 'tempfile'
require 'chef/api_client'
require 'chef/rest/auth_credentials'
require 'chef/rest/rest_request'
require 'chef/monkey_patches/string'

class Chef
  # == Chef::REST
  # Chef's custom REST client with built-in JSON support and RSA signed header
  # authentication.
  class REST
    attr_reader :auth_credentials
    attr_accessor :url, :cookies, :sign_on_redirect, :redirect_limit

    # Create a REST client object. The supplied +url+ is used as the base for
    # all subsequent requests. For example, when initialized with a base url
    # http://localhost:4000, a call to +get_rest+ with 'nodes' will make an
    # HTTP GET request to http://localhost:4000/nodes
    def initialize(url, client_name=Chef::Config[:node_name], signing_key_filename=Chef::Config[:client_key], options={})
      @url = url
      @cookies = CookieJar.instance
      @default_headers = options[:headers] || {}
      @auth_credentials = AuthCredentials.new(client_name, signing_key_filename)
      @sign_on_redirect, @sign_request = true, true
      @redirects_followed = 0
      @redirect_limit = 10
    end

    def signing_key_filename
      @auth_credentials.key_file
    end

    def client_name
      @auth_credentials.client_name
    end

    def signing_key
      @auth_credentials.raw_key
    end

    # Register the client
    def register(name=Chef::Config[:node_name], destination=Chef::Config[:client_key])
      if (File.exists?(destination) &&  !File.writable?(destination))
        raise Chef::Exceptions::CannotWritePrivateKey, "I cannot write your private key to #{destination} - check permissions?"
      end
      nc = Chef::ApiClient.new
      nc.name(name)

      catch(:done) do
        retries = config[:client_registration_retries] || 5
        0.upto(retries) do |n|
          begin
            response = nc.save(true, true)
            Chef::Log.debug("Registration response: #{response.inspect}")
            raise Chef::Exceptions::CannotWritePrivateKey, "The response from the server did not include a private key!" unless response.has_key?("private_key")
            # Write out the private key
            file = ::File.open(destination, File::WRONLY|File::EXCL|File::CREAT, 0600)
            file.print(response["private_key"])
            file.close
            throw :done
          rescue IOError
            raise Chef::Exceptions::CannotWritePrivateKey, "I cannot write your private key to #{destination}"
          rescue Net::HTTPFatalError => e
            Chef::Log.warn("Failed attempt #{n} of #{retries+1} on client creation")
            raise unless e.response.code == "500"
          end
        end
      end

      true
    end

    # Send an HTTP GET request to the path
    #
    # Using this method to +fetch+ a file is considered deprecated.
    #
    # === Parameters
    # path:: The path to GET
    # raw:: Whether you want the raw body returned, or JSON inflated.  Defaults
    #   to JSON inflated.
    def get_rest(path, raw=false, headers={})
      if raw
        streaming_request(create_url(path), headers)
      else
        api_request(:GET, create_url(path), headers)
      end
    end

    # Send an HTTP DELETE request to the path
    def delete_rest(path, headers={})
      api_request(:DELETE, create_url(path), headers)
    end

    # Send an HTTP POST request to the path
    def post_rest(path, json, headers={})
      api_request(:POST, create_url(path), headers, json)
    end

    # Send an HTTP PUT request to the path
    def put_rest(path, json, headers={})
      api_request(:PUT, create_url(path), headers, json)
    end

    # Streams a download to a tempfile, then yields the tempfile to a block.
    # After the download, the tempfile will be closed and unlinked.
    # If you rename the tempfile, it will not be deleted.
    # Beware that if the server streams infinite content, this method will
    # stream it until you run out of disk space.
    def fetch(path, headers={})
      streaming_request(create_url(path), headers) {|tmp_file| yield tmp_file }
    end

    def create_url(path)
      if path =~ /^(http|https):\/\//
        URI.parse(path)
      else
        URI.parse("#{@url}/#{path}")
      end
    end

    def sign_requests?
      auth_credentials.sign_requests? && @sign_request
    end

    # ==== DEPRECATED
    # Use +api_request+ instead
    #--
    # Actually run an HTTP request.  First argument is the HTTP method,
    # which should be one of :GET, :PUT, :POST or :DELETE.  Next is the
    # URL, then an object to include in the body (which will be converted with
    # .to_json). The limit argument is unused, it is present for backwards
    # compatibility. Configure the redirect limit with #redirect_limit=
    # instead.
    #
    # Typically, you won't use this method -- instead, you'll use one of
    # the helper methods (get_rest, post_rest, etc.)
    #
    # Will return the body of the response on success.
    def run_request(method, url, headers={}, data=false, limit=nil, raw=false)
      json_body = data ? data.to_json : nil
      headers = build_headers(method, url, headers, json_body, raw)

      tf = nil

      retriable_rest_request(method, url, json_body, headers) do |rest_request|

        res = rest_request.call do |response|
          if raw
            tf = stream_to_tempfile(url, response)
          else
            response.read_body
          end
        end

        if res.kind_of?(Net::HTTPSuccess)
          if res['content-type'] =~ /json/
            response_body = res.body.chomp
            JSON.parse(response_body)
          else
            if method == :HEAD
              true
            elsif raw
              tf
            else
              res.body
            end
          end
        elsif res.kind_of?(Net::HTTPFound) or res.kind_of?(Net::HTTPMovedPermanently)
          follow_redirect {run_request(:GET, create_url(res['location']), {}, false, nil, raw)}
        elsif res.kind_of?(Net::HTTPNotModified)
          false
        else
          if res['content-type'] =~ /json/
            exception = JSON.parse(res.body)
            msg = "HTTP Request Returned #{res.code} #{res.message}: "
            msg << (exception["error"].respond_to?(:join) ? exception["error"].join(", ") : exception["error"].to_s)
            Chef::Log.warn(msg)
          end
          res.error!
        end
      end
    end

    # Runs an HTTP request to a JSON API. File Download not supported.
    def api_request(method, url, headers={}, data=false)
      json_body = data ? data.to_json : nil
      headers = build_headers(method, url, headers, json_body)

      retriable_rest_request(method, url, json_body, headers) do |rest_request|
        response = rest_request.call {|r| r.read_body}

        if response.kind_of?(Net::HTTPSuccess)
          if response['content-type'] =~ /json/
            JSON.parse(response.body.chomp)
          else
            Chef::Log.warn("Expected JSON response, but got content-type '#{response['content-type']}'")
            response.body
          end
        elsif redirect_location = redirected_to(response)
          follow_redirect {api_request(:GET, create_url(redirect_location))}
        else
          if response['content-type'] =~ /json/
            exception = JSON.parse(response.body)
            msg = "HTTP Request Returned #{response.code} #{response.message}: "
            msg << (exception["error"].respond_to?(:join) ? exception["error"].join(", ") : exception["error"].to_s)
            Chef::Log.warn(msg)
          end
          response.error!
        end
      end
    end

    # Makes a streaming download request. <b>Doesn't speak JSON.</b>
    # Streams the response body to a tempfile. If a block is given, it's
    # passed to Tempfile.open(), which means that the tempfile will automatically
    # be unlinked after the block is executed.
    #
    # If no block is given, the tempfile is returned, which means it's up to
    # you to unlink the tempfile when you're done with it.
    def streaming_request(url, headers, &block)
      headers = build_headers(:GET, url, headers, nil, true)
      retriable_rest_request(:GET, url, nil, headers) do |rest_request|
        tempfile = nil
        response = rest_request.call do |r| 
          if block_given? && r.kind_of?(Net::HTTPSuccess)
            begin
              tempfile = stream_to_tempfile(url, r, &block)
              yield tempfile
            ensure
              tempfile.close!
            end
          else
            tempfile = stream_to_tempfile(url, r)
          end
        end
        if response.kind_of?(Net::HTTPSuccess)
          tempfile
        elsif redirect_location = redirected_to(response)
          # TODO: test tempfile unlinked when following redirects.
          tempfile && tempfile.close!
          follow_redirect {streaming_request(create_url(redirect_location), {}, &block)}
        else
          tempfile && tempfile.close!
          response.error!
        end
      end
    end

    def retriable_rest_request(method, url, req_body, headers)
      rest_request = Chef::REST::RESTRequest.new(method, url, req_body, headers)

      Chef::Log.debug("Sending HTTP Request via #{method} to #{url.host}:#{url.port}#{rest_request.path}")

      http_attempts = 0

      begin
        http_attempts += 1

        res = yield rest_request

      rescue Errno::ECONNREFUSED
        if http_retry_count - http_attempts + 1 > 0
          Chef::Log.error("Connection refused connecting to #{url.host}:#{url.port} for #{rest_request.path}, retry #{http_attempts}/#{http_retry_count}")
          sleep(http_retry_delay)
          retry
        end
        raise Errno::ECONNREFUSED, "Connection refused connecting to #{url.host}:#{url.port} for #{rest_request.path}, giving up"
      rescue Timeout::Error
        if http_retry_count - http_attempts + 1 > 0
          Chef::Log.error("Timeout connecting to #{url.host}:#{url.port} for #{rest_request.path}, retry #{http_attempts}/#{http_retry_count}")
          sleep(http_retry_delay)
          retry
        end
        raise Timeout::Error, "Timeout connecting to #{url.host}:#{url.port} for #{rest_request.path}, giving up"
      rescue Net::HTTPServerException
        if res.kind_of?(Net::HTTPForbidden)
          if http_retry_count - http_attempts + 1 > 0
            Chef::Log.error("Received 403 Forbidden against #{url.host}:#{url.port} for #{rest_request.path}, retry #{http_attempts}/#{http_retry_count}")
            sleep(http_retry_delay)
            retry
          end
        end
        raise
      end
    end

    def authentication_headers(method, url, json_body=nil)
      request_params = {:http_method => method, :path => url.path, :body => json_body, :host => "#{url.host}:#{url.port}"}
      request_params[:body] ||= ""
      auth_credentials.signature_headers(request_params)
    end

    def http_retry_delay
      config[:http_retry_delay]
    end

    def http_retry_count
      config[:http_retry_count]
    end

    def config
      Chef::Config
    end

    def follow_redirect
      raise Chef::Exceptions::RedirectLimitExceeded if @redirects_followed >= redirect_limit
      @redirects_followed += 1
      Chef::Log.debug("Following redirect #{@redirects_followed}/#{redirect_limit}")
      if @sign_on_redirect
        yield
      else
        @sign_request = false
        yield
      end
    ensure
      @redirects_followed = 0
      @sign_request = true
    end

    private

    def redirected_to(response)
      if response.kind_of?(Net::HTTPFound) || response.kind_of?(Net::HTTPMovedPermanently)
        response['location']
      else
        nil
      end
    end

    def build_headers(method, url, headers={}, json_body=false, raw=false)
      headers                 = @default_headers.merge(headers)
      headers['Accept']       = "application/json" unless raw
      headers["Content-Type"] = 'application/json' if json_body
      headers['Content-Length'] = json_body.bytesize.to_s if json_body
      headers.merge!(authentication_headers(method, url, json_body)) if sign_requests?
      headers
    end

    def stream_to_tempfile(url, response)
      tf = Tempfile.open("chef-rest")
      if RUBY_PLATFORM =~ /mswin|mingw32|windows/
        tf.binmode #required for binary files on Windows platforms
      end
      Chef::Log.debug("Streaming download from #{url.to_s} to tempfile #{tf.path}")
      # Stolen from http://www.ruby-forum.com/topic/166423
      # Kudos to _why!
      size, total = 0, response.header['Content-Length'].to_i
      response.read_body do |chunk|
        tf.write(chunk)
        size += chunk.size
        if Chef::Log.verbose
          if size == 0
            Chef::Log.debug("#{url.path} done (0 length file)")
          elsif total == 0
            Chef::Log.debug("#{url.path} (zero content length or no Content-Length header)")
          else
            Chef::Log.debug("#{url.path}" + " %d%% done (%d of %d)" % [(size * 100) / total, size, total])
          end
        end
      end
      tf.close
      tf
    rescue Exception
      tf.close!
      raise
    end

  end
end
