module Fog
  module AWS
    class Compute
      class Real

        # Reboot specified instances
        #
        # ==== Parameters
        # * instance_id<~Array> - Ids of instances to reboot
        #
        # ==== Returns
        # # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'requestId'<~String> - Id of request
        #     * 'return'<~Boolean> - success?
        def reboot_instances(instance_id = [])
          params = AWS.indexed_param('InstanceId', instance_id)
          request({
            'Action'    => 'RebootInstances',
            :idempotent => true,
            :parser     => Fog::Parsers::AWS::Compute::Basic.new
          }.merge!(params))
        end

      end

      class Mock

        def reboot_instances(instance_id = [])
          response = Excon::Response.new
          instance_id = [*instance_id]
          if (@data[:instances].keys & instance_id).length == instance_id.length
            for instance_id in instance_id
              @data[:instances][instance_id]['status'] = 'rebooting'
            end
            response.status = 200
            response.body = {
              'requestId' => Fog::AWS::Mock.request_id,
              'return'    => true
            }
            response
          else
            raise Fog::AWS::Compute::NotFound.new("The instance ID #{instance_id.inspect} does not exist")
          end
        end

      end
    end
  end
end
