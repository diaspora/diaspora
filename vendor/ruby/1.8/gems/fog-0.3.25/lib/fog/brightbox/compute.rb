module Fog
  module Brightbox
    class Compute < Fog::Service

      API_URL = "https://api.gb1.brightbox.com/"

      requires :brightbox_client_id, :brightbox_secret

      model_path 'fog/brightbox/models/compute'
      model :account # Singular resource, no collection
      collection :servers
      model :server
      collection :flavors
      model :flavor
      collection :images
      model :image
      collection :zones
      model :zone
      collection :cloud_ips
      model :cloud_ip
      collection :users
      model :user

      request_path 'fog/brightbox/requests/compute'
      request :create_api_client
      request :create_cloud_ip
      request :create_image
      request :create_server
      request :destroy_api_client
      request :destroy_cloud_ip
      request :destroy_image
      request :destroy_server
      request :get_account
      request :get_api_client
      request :get_cloud_ip
      request :get_image
      request :get_interface
      request :get_server
      request :get_server_type
      request :get_user
      request :get_zone
      request :list_api_clients
      request :list_cloud_ips
      request :list_images
      request :list_server_types
      request :list_servers
      request :list_users
      request :list_zones
      request :map_cloud_ip
      request :reset_ftp_password_account
      request :resize_server
      request :shutdown_server
      request :snapshot_server
      request :start_server
      request :stop_server
      request :unmap_cloud_ip
      request :update_account
      request :update_api_client
      request :update_image
      request :update_server
      request :update_user

      class Mock

        def initialize(options)
          @brightbox_client_id = options[:brightbox_client_id] || Fog.credentials[:brightbox_client_id]
          @brightbox_secret = options[:brightbox_secret] || Fog.credentials[:brightbox_secret]
        end

        def request(options)
          raise "Not implemented"
        end
      end

      class Real

        def initialize(options)
          require "json"
          # Currently authentication and api endpoints are the same but may change
          @auth_url = options[:brightbox_auth_url] || Fog.credentials[:brightbox_auth_url] || API_URL
          @api_url = options[:brightbox_api_url] || Fog.credentials[:brightbox_api_url] || API_URL
          @brightbox_client_id = options[:brightbox_client_id] || Fog.credentials[:brightbox_client_id]
          @brightbox_secret = options[:brightbox_secret] || Fog.credentials[:brightbox_secret]
          @connection = Fog::Connection.new(@api_url)
        end

        def request(params)
          begin
            get_oauth_token if @oauth_token.nil?
            response = authenticated_request(params)
          rescue Excon::Errors::Unauthorized => e
            get_oauth_token
            response = authenticated_request(params)
          end
          unless response.body.empty?
            response = JSON.parse(response.body)
          end
        end

        def account
          Fog::Brightbox::Compute::Account.new(get_account)
        end

      private
        def get_oauth_token(options = {})
          auth_url = options[:brightbox_auth_url] || @auth_url

          connection = Fog::Connection.new(auth_url)
          @authentication_body = {'client_id' => @brightbox_client_id, 'grant_type' => 'none'}.to_json

          response = connection.request({
            :path => "/token",
            :expects  => 200,
            :headers  => {
              'Authorization' => "Basic " + Base64.encode64("#{@brightbox_client_id}:#{@brightbox_secret}").chomp,
              'Content-Type' => 'application/json'
            },
            :method   => 'POST',
            :body     => @authentication_body
          })
          @oauth_token = JSON.parse(response.body)["access_token"]
          return @oauth_token
        end

        def authenticated_request(options)
          headers = options[:headers] || {}
          headers.merge!("Authorization" => "OAuth #{@oauth_token}")
          options[:headers] = headers
          @connection.request(options)
        end
      end
    end
  end
end