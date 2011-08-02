require 'fog/core/parser'

module Fog
  module NewServers
    class Compute < Fog::Service

      requires :new_servers_password
      requires :new_servers_username

      model_path 'fog/new_servers/models/compute'

      request_path 'fog/new_servers/requests/compute'
      request :add_server
      request :cancel_server
      request :get_server
      request :list_images
      request :list_plans
      request :list_servers
      request :reboot_server

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
          @new_server_username = options[:new_servers_username]
          @data = self.class.data[@new_server_username]
        end

      end

      class Real

        def initialize(options={})
          @new_servers_password = options[:new_servers_password]
          @new_servers_username = options[:new_servers_username]
          @host   = options[:host]    || "noc.newservers.com"
          @port   = options[:port]    || 443
          @scheme = options[:scheme]  || 'https'
          @connection = Fog::Connection.new("#{@scheme}://#{@host}:#{@port}", options[:persistent])
        end

        def reload
          @connection.reset
        end

        def request(params)
          params[:query] ||= {}
          params[:query].merge!({
            :password => @new_servers_password,
            :username => @new_servers_username
          })
          params[:headers] ||= {}
          case params[:method]
          when 'DELETE', 'GET', 'HEAD'
            params[:headers]['Accept'] = 'application/xml'
          when 'POST', 'PUT'
            params[:headers]['Content-Type'] = 'application/xml'
          end

          begin
            response = @connection.request(params.merge!({:host => @host}))
          rescue Excon::Errors::Error => error
            raise case error
            when Excon::Errors::NotFound
              Fog::NewServers::Compute::NotFound.slurp(error)
            else
              error
            end
          end

          response
        end

      end
    end
  end
end
