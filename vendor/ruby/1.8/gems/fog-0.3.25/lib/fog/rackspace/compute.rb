module Fog
  module Rackspace
    class Compute < Fog::Service

      requires :rackspace_api_key, :rackspace_username

      model_path 'fog/rackspace/models/compute'
      model       :flavor
      collection  :flavors
      model       :image
      collection  :images
      model       :server
      collection  :servers

      request_path 'fog/rackspace/requests/compute'
      request :create_image
      request :create_server
      request :delete_image
      request :delete_server
      request :get_flavor_details
      request :get_image_details
      request :get_server_details
      request :list_addresses
      request :list_private_addresses
      request :list_public_addresses
      request :list_flavors
      request :list_flavors_detail
      request :list_images
      request :list_images_detail
      request :list_servers
      request :list_servers_detail
      request :reboot_server
      request :update_server

      class Mock

        def self.data
          @data ||= Hash.new do |hash, key|
            hash[key] = {
              :last_modified => {
                :images  => {},
                :servers => {}
              },
              :images  => {},
              :servers => {}
            }
          end
        end

        def self.reset_data(keys=data.keys)
          for key in [*keys]
            data.delete(key)
          end
        end

        def initialize(options={})
          @rackspace_username = options[:rackspace_username]
          @data = self.class.data[@rackspace_username]
        end

      end

      class Real

        def initialize(options={})
          require 'json'
          credentials = Fog::Rackspace.authenticate(options)
          @auth_token = credentials['X-Auth-Token']
          uri = URI.parse(credentials['X-Server-Management-Url'])
          @host   = uri.host
          @path   = uri.path
          @port   = uri.port
          @scheme = uri.scheme
          @connection = Fog::Connection.new("#{@scheme}://#{@host}:#{@port}", options[:persistent])
        end

        def reload
          @connection.reset
        end

        def request(params)
          begin
            response = @connection.request(params.merge!({
              :headers  => {
                'Content-Type' => 'application/json',
                'X-Auth-Token' => @auth_token
              }.merge!(params[:headers] || {}),
              :host     => @host,
              :path     => "#{@path}/#{params[:path]}"
            }))
          rescue Excon::Errors::Error => error
            raise case error
            when Excon::Errors::NotFound
              Fog::Rackspace::Compute::NotFound.slurp(error)
            else
              error
            end
          end
          unless response.body.empty?
            response.body = JSON.parse(response.body)
          end
          response
        end

      end
    end
  end
end
