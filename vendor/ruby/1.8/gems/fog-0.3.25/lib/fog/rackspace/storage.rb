module Fog
  module Rackspace
    class Storage < Fog::Service

      requires :rackspace_api_key, :rackspace_username

      model_path 'fog/rackspace/models/storage'
      model       :directory
      collection  :directories
      model       :file
      collection  :files

      request_path 'fog/rackspace/requests/storage'
      request :delete_container
      request :delete_object
      request :get_container
      request :get_containers
      request :get_object
      request :head_container
      request :head_containers
      request :head_object
      request :put_container
      request :put_object

      module Utils

        def cdn
          @cdn ||= Fog::Rackspace::CDN.new(
            :rackspace_api_key => @rackspace_api_key,
            :rackspace_username => @rackspace_username
          )
        end

        def parse_data(data)
          metadata = {
            :body => nil,
            :headers => {}
          }

          if data.is_a?(String)
            metadata[:body] = data
            metadata[:headers]['Content-Length'] = metadata[:body].size.to_s
          else
            filename = ::File.basename(data.path)
            unless (mime_types = MIME::Types.of(filename)).empty?
              metadata[:headers]['Content-Type'] = mime_types.first.content_type
            end
            metadata[:body] = data.read
            metadata[:headers]['Content-Length'] = ::File.size(data.path).to_s
          end
          # metadata[:headers]['Content-MD5'] = Base64.encode64(Digest::MD5.digest(metadata[:body])).strip
          metadata
        end

      end

      class Mock
        include Utils

        def self.data
          @data ||= Hash.new do |hash, key|
            hash[key] = {}
          end
        end

        def self.reset_data(keys=data.keys)
          for key in [*keys]
            data.delete(key)
          end
        end

        def initialize(options={})
          require 'mime/types'
          @rackspace_api_key = options[:rackspace_api_key]
          @rackspace_username = options[:rackspace_username]
          @data = self.class.data[@rackspace_username]
        end

      end

      class Real
        include Utils

        def initialize(options={})
          require 'mime/types'
          require 'json'
          @rackspace_api_key = options[:rackspace_api_key]
          @rackspace_username = options[:rackspace_username]
          credentials = Fog::Rackspace.authenticate(options)
          @auth_token = credentials['X-Auth-Token']

          uri = URI.parse(credentials['X-Storage-Url'])
          @host   = uri.host
          @path   = uri.path
          @port   = uri.port
          @scheme = uri.scheme
          @connection = Fog::Connection.new("#{@scheme}://#{@host}:#{@port}", options[:persistent])
        end

        def reload
          @storage_connection.reset
        end

        def request(params, parse_json = true, &block)
          begin
            response = @connection.request(params.merge!({
              :headers  => {
                'Content-Type' => 'application/json',
                'X-Auth-Token' => @auth_token
              }.merge!(params[:headers] || {}),
              :host     => @host,
              :path     => "#{@path}/#{params[:path]}",
            }), &block)
          rescue Excon::Errors::Error => error
            raise case error
            when Excon::Errors::NotFound
              Fog::Rackspace::Storage::NotFound.slurp(error)
            else
              error
            end
          end
          if !response.body.empty? && parse_json && response.headers['Content-Type'] =~ %r{application/json}
            response.body = JSON.parse(response.body)
          end
          response
        end

      end
    end
  end
end
