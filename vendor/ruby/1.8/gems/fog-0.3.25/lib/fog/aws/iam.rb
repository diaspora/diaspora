module Fog
  module AWS
    class IAM < Fog::Service

      requires :aws_access_key_id, :aws_secret_access_key

      request_path 'fog/aws/requests/iam'
      request :add_user_to_group
      request :create_access_key
      request :create_group
      request :create_user
      request :delete_access_key
      request :delete_group
      request :delete_group_policy
      request :delete_user
      request :delete_user_policy
      request :list_access_keys
      request :list_groups
      request :list_group_policies
      request :list_user_policies
      request :list_users
      request :put_group_policy
      request :put_user_policy
      request :remove_user_from_group
      request :update_access_key

      class Mock

        def initialize(options={})
        end

      end

      class Real

        # Initialize connection to IAM
        #
        # ==== Notes
        # options parameter must include values for :aws_access_key_id and
        # :aws_secret_access_key in order to create a connection
        #
        # ==== Examples
        #   iam = IAM.new(
        #    :aws_access_key_id => your_aws_access_key_id,
        #    :aws_secret_access_key => your_aws_secret_access_key
        #   )
        #
        # ==== Parameters
        # * options<~Hash> - config arguments for connection.  Defaults to {}.
        #
        # ==== Returns
        # * IAM object with connection to AWS.
        def initialize(options={})
          require 'json'
          @aws_access_key_id      = options[:aws_access_key_id]
          @aws_secret_access_key  = options[:aws_secret_access_key]
          @hmac       = Fog::HMAC.new('sha256', @aws_secret_access_key)
          @host       = options[:host]      || 'iam.amazonaws.com'
          @path       = options[:path]      || '/'
          @port       = options[:port]      || 443
          @scheme     = options[:scheme]    || 'https'
          @connection = Fog::Connection.new("#{@scheme}://#{@host}:#{@port}#{@path}", options[:persistent])
        end

        def reload
          @connection.reset
        end

        private

        def request(params)
          idempotent  = params.delete(:idempotent)
          parser      = params.delete(:parser)

          body = AWS.signed_params(
            params,
            {
              :aws_access_key_id  => @aws_access_key_id,
              :hmac               => @hmac,
              :host               => @host,
              :path               => @path,
              :version            => '2010-05-08'
            }
          )

          response = @connection.request({
            :body       => body,
            :expects    => 200,
            :idempotent => idempotent,
            :headers    => { 'Content-Type' => 'application/x-www-form-urlencoded' },
            :host       => @host,
            :method     => 'POST',
            :parser     => parser
          })

          response
        end

      end
    end
  end
end
