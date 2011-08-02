module Fog
  module AWS
    class ELB < Fog::Service

      requires :aws_access_key_id, :aws_secret_access_key

      request_path 'fog/aws/requests/elb'
      request :create_load_balancer
      request :delete_load_balancer
      request :deregister_instances_from_load_balancer
      request :describe_instance_health
      request :describe_load_balancers
      request :disable_availability_zones_for_load_balancer
      request :enable_availability_zones_for_load_balancer
      request :register_instances_with_load_balancer

      class Mock

        def initialize(options={})
        end

      end

      class Real

        # Initialize connection to ELB
        #
        # ==== Notes
        # options parameter must include values for :aws_access_key_id and
        # :aws_secret_access_key in order to create a connection
        #
        # ==== Examples
        #   elb = ELB.new(
        #    :aws_access_key_id => your_aws_access_key_id,
        #    :aws_secret_access_key => your_aws_secret_access_key
        #   )
        #
        # ==== Parameters
        # * options<~Hash> - config arguments for connection.  Defaults to {}.
        #   * region<~String> - optional region to use, in ['eu-west-1', 'us-east-1', 'us-west-1'i, 'ap-southeast-1']
        #
        # ==== Returns
        # * ELB object with connection to AWS.
        def initialize(options={})
          @aws_access_key_id      = options[:aws_access_key_id]
          @aws_secret_access_key  = options[:aws_secret_access_key]
          @hmac = Fog::HMAC.new('sha256', @aws_secret_access_key)
          options[:region] ||= 'us-east-1'
          @host = options[:host] || case options[:region]
          when 'ap-southeast-1'
            'elasticloadbalancing.ap-southeast-1.amazonaws.com'
          when 'eu-west-1'
            'elasticloadbalancing.eu-west-1.amazonaws.com'
          when 'us-east-1'
            'elasticloadbalancing.us-east-1.amazonaws.com'
          when 'us-west-1'
            'elasticloadbalancing.us-west-1.amazonaws.com'
          else
            raise ArgumentError, "Unknown region: #{options[:region].inspect}"
          end
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
              :version            => '2009-11-25'
            }
          )

          response = @connection.request({
            :body       => body,
            :expects    => 200,
            :headers    => { 'Content-Type' => 'application/x-www-form-urlencoded' },
            :idempotent => idempotent,
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
