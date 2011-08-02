module Fog
  module GoGrid
    class Compute < Fog::Service

      requires :go_grid_api_key
      requires :go_grid_shared_secret

      model_path 'fog/go_grid/models/compute'
      model         :image
      collection    :images
      model         :server
      collection    :servers

      request_path 'fog/go_grid/requests/compute'
      request :common_lookup_list
      request :grid_image_get
      request :grid_image_list
      request :grid_ip_list
      request :grid_loadbalancer_list
      request :grid_server_add
      request :grid_server_delete
      request :grid_server_get
      request :grid_server_list
      request :grid_server_power

      class Mock

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
          @go_grid_api_key = options[:go_grid_api_key]
          @go_grid_shared_secret = options[:go_grid_shared_secret]
          @data = self.class.data[@go_grid_api_key]
        end

      end

      class Real

        def initialize(options={})
          require 'digest/md5'
          require 'json'
          @go_grid_api_key = options[:go_grid_api_key]
          @go_grid_shared_secret = options[:go_grid_shared_secret]
          @host   = options[:host]    || "api.gogrid.com"
          @path   = options[:path]    || "/api"
          @port   = options[:port]    || 443
          @scheme = options[:scheme]  || 'https'
          @connection = Fog::Connection.new("#{@scheme}://#{@host}:#{@port}", options[:persistent])
        end

        def reload
          @connection.reset
        end

        def request(params)
          params = {
            :expects  => 200,
            :method   => 'GET'
          }.merge!(params)

          params[:query] ||= {}
          params[:query].merge!({
            'api_key' => @go_grid_api_key,
            'format'  => 'json',
            'sig'     => Digest::MD5.hexdigest("#{@go_grid_api_key}#{@go_grid_shared_secret}#{Time.now.to_i}"),
            'v'       => '1.5'
          })

          begin
            response = @connection.request(
              params.merge!(:path => "#{@path}/#{params[:path]}")
            )
          rescue Excon::Errors::Error => error
            raise case error
            when Excon::Errors::NotFound
              Fog::GoGrid::Compute::NotFound.slurp(error)
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
