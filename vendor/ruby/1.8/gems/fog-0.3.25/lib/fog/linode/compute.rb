module Fog
  module Linode
    class Compute < Fog::Service

      requires :linode_api_key

      model_path 'fog/linode/models/compute'

      request_path 'fog/linode/requests/compute'
      request :avail_datacenters
      request :avail_distributions
      request :avail_kernels
      request :avail_linodeplans
      request :avail_stackscripts
      request :linode_create
      request :linode_delete
      request :linode_list
      request :linode_reboot

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
          @linode_api_key = options[:linode_api_key]
          @data = self.class.data[@linode_api_key]
        end

      end

      class Real

        def initialize(options={})
          require 'json'
          @linode_api_key = options[:linode_api_key]
          @host   = options[:host]    || "api.linode.com"
          @port   = options[:port]    || 443
          @scheme = options[:scheme]  || 'https'
          @connection = Fog::Connection.new("#{@scheme}://#{@host}:#{@port}", options[:persistent])
        end

        def reload
          @connection.reset
        end

        def request(params)
          params[:query] ||= {}
          params[:query].merge!(:api_key => @linode_api_key)

          response = @connection.request(params.merge!({:host => @host}))

          unless response.body.empty?
            response.body = JSON.parse(response.body)
            if data = response.body['ERRORARRAY'].first
              error = case data['ERRORCODE']
              when 5
                Fog::Linode::Compute::NotFound
              else
                Fog::Linode::Compute::Error
              end
              raise error.new(data['ERRORMESSAGE'])
            end
          end
          response
        end

      end
    end
  end
end
