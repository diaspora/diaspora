module Fog
  module Bluebox
    class Compute < Fog::Service

      requires :bluebox_api_key, :bluebox_customer_id

      model_path 'fog/bluebox/models/compute'
      model       :flavor
      collection  :flavors
      model       :image
      collection  :images
      model       :server
      collection  :servers

      request_path 'fog/bluebox/requests/compute'
      request :create_block
      request :destroy_block
      request :get_block
      request :get_blocks
      request :get_product
      request :get_products
      request :get_template
      request :get_templates
      request :reboot_block

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
          @bluebox_api_key = options[:bluebox_api_key]
          @data = self.class.data[@bluebox_api_key]
        end

      end

      class Real

        def initialize(options={})
          require 'json'
          @bluebox_api_key      = options[:bluebox_api_key]
          @bluebox_customer_id  = options[:bluebox_customer_id]
          @host   = options[:bluebox_host]    || "boxpanel.blueboxgrp.com"
          @port   = options[:bluebox_port]    || 443
          @scheme = options[:bluebox_scheme]  || 'https'
          @connection = Fog::Connection.new("#{@scheme}://#{@host}:#{@port}", options[:persistent])
        end

        def reload
          @connection.reset
        end

        def request(params)
          params[:headers] ||= {}
          params[:headers].merge!({
            'Authorization' => "Basic #{Base64.encode64([@bluebox_customer_id, @bluebox_api_key].join(':')).delete("\r\n")}"
          })

          begin
            response = @connection.request(params.merge!({:host => @host}))
          rescue Excon::Errors::Error => error
            raise case error
            when Excon::Errors::NotFound
              Fog::Bluebox::Compute::NotFound.slurp(error)
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
