module Fog
  module AWS
    class Compute
      class Real

        require 'fog/aws/parsers/compute/describe_instances'

        # Describe all or specified instances
        #
        # ==== Parameters
        # * filters<~Hash> - List of filters to limit results with
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'requestId'<~String> - Id of request
        #     * 'reservationSet'<~Array>:
        #       * 'groupSet'<~Array> - Group names for reservation
        #       * 'ownerId'<~String> - AWS Access Key ID of reservation owner
        #       * 'reservationId'<~String> - Id of the reservation
        #       * 'instancesSet'<~Array>:
        #         * instance<~Hash>:
        #           * 'architecture'<~String> - architecture of image in [i386, x86_64]
        #           * 'amiLaunchIndex'<~Integer> - reference to instance in launch group
        #           * 'blockDeviceMapping'<~Array>
        #             * 'attachTime'<~Time> - time of volume attachment
        #             * 'deleteOnTermination'<~Boolean> - whether or not to delete volume on termination
        #             * 'deviceName'<~String> - specifies how volume is exposed to instance
        #             * 'status'<~String> - status of attached volume
        #             * 'volumeId'<~String> - Id of attached volume
        #           * 'dnsName'<~String> - public dns name, blank until instance is running
        #           * 'imageId'<~String> - image id of ami used to launch instance
        #           * 'instanceId'<~String> - id of the instance
        #           * 'instanceState'<~Hash>:
        #             * 'code'<~Integer> - current status code
        #             * 'name'<~String> - current status name
        #           * 'instanceType'<~String> - type of instance
        #           * 'ipAddress'<~String> - public ip address assigned to instance
        #           * 'kernelId'<~String> - id of kernel used to launch instance
        #           * 'keyName'<~String> - name of key used launch instances or blank
        #           * 'launchTime'<~Time> - time instance was launched
        #           * 'monitoring'<~Hash>:
        #             * 'state'<~Boolean - state of monitoring
        #           * 'placement'<~Hash>:
        #             * 'availabilityZone'<~String> - Availability zone of the instance
        #           * 'productCodes'<~Array> - Product codes for the instance
        #           * 'privateDnsName'<~String> - private dns name, blank until instance is running
        #           * 'privateIpAddress'<~String> - private ip address assigned to instance
        #           * 'rootDeviceName'<~String> - specifies how the root device is exposed to the instance
        #           * 'rootDeviceType'<~String> - root device type used by AMI in [ebs, instance-store]
        #           * 'ramdiskId'<~String> - Id of ramdisk used to launch instance
        #           * 'reason'<~String> - reason for most recent state transition, or blank
        def describe_instances(filters = {})
          unless filters.is_a?(Hash)
            Formatador.display_line("[yellow][WARN] describe_instances with #{filters.class} param is deprecated, use describe_instances('instance-id' => []) instead[/] [light_black](#{caller.first})[/]")
            filters = {'instance-id' => [*filters]}
          end
          params = AWS.indexed_filters(filters)

          request({
            'Action'    => 'DescribeInstances',
            :idempotent => true,
            :parser     => Fog::Parsers::AWS::Compute::DescribeInstances.new
          }.merge!(params))
        end

      end

      class Mock

        def describe_instances(filters = {})
          unless filters.is_a?(Hash)
            Formatador.display_line("[yellow][WARN] describe_instances with #{filters.class} param is deprecated, use describe_instances('instance-id' => []) instead[/] [light_black](#{caller.first})[/]")
            filters = {'instance-id' => [*filters]}
          end

          if filters.keys.any? {|key| key =~ /^tag/}
            Formatador.display_line("[yellow][WARN] describe_instances tag filters are not yet mocked[/] [light_black](#{caller.first})[/]")
            Fog::Mock.not_implemented
          end

          response = Excon::Response.new

          instance_set = @data[:instances].values

          aliases = {
            'architecture'      => 'architecture',
            'availability-zone' => 'availabilityZone',
            'client-token'      => 'clientToken',
            'dns-token'         => 'dnsName',
            'group-id'          => 'groupId',
            'image-id'          => 'imageId',
            'instance-id'       => 'instanceId',
            'instance-lifecycle'  => 'instanceLifecycle',
            'instance-type'     => 'instanceType',
            'ip-address'        => 'ipAddress',
            'kernel-id'         => 'kernelId',
            'key-name'          => 'key-name',
            'launch-index'      => 'launchIndex',
            'launch-time'       => 'launchTime',
            'monitoring-state'  => 'monitoringState',
            'owner-id'          => 'ownerId',
            'placement-group-name' => 'placementGroupName',
            'platform'          => 'platform',
            'private-dns-name'  => 'privateDnsName',
            'private-ip-address'  => 'privateIpAddress',
            'product-code'      => 'productCode',
            'ramdisk-id'        => 'ramdiskId',
            'reason'            => 'reason',
            'requester-id'      => 'requesterId',
            'reservation-id'    => 'reservationId',
            'root-device-name'  => 'rootDeviceName',
            'root-device-type'  => 'rootDeviceType',
            'spot-instance-request-id' => 'spotInstanceRequestId',
            'subnet-id'         => 'subnetId',
            'virtualization-type' => 'virtualizationType',
            'vpc-id'            => 'vpcId'
          }
          block_device_mapping_aliases = {
            'attach-time'           => 'attachTime',
            'delete-on-termination' => 'deleteOnTermination',
            'device-name'           => 'deviceName',
            'status'                => 'status',
            'volume-id'             => 'volumeId',
          }
          instance_state_aliases = {
            'code' => 'code',
            'name' => 'name'
          }
          state_reason_aliases = {
            'code'    => 'code',
            'message' => 'message'
          }
          for filter_key, filter_value in filters
            if block_device_mapping_key = filter_key.split('block-device-mapping.')[1]
              aliased_key = block_device_mapping_aliases[block_device_mapping_key]
              instance_set = instance_set.reject{|instance| !instance['blockDeviceMapping'].detect {|block_device_mapping| [*filter_value].include?(block_device_mapping[aliased_key])}}
            elsif instance_state_key = filter_key.split('instance-state-')[1]
              aliased_key = instance_state_aliases[instance_state_key]
              instance_set = instance_set.reject{|instance| ![*filter_value].include?(instance['instanceState'][aliased_key])}
            elsif state_reason_key = filter_key.split('state-reason-')[1]
              aliased_key = state_reason_aliases[state_reason_key]
              instance_set = instance_set.reject{|instance| ![*filter_value].include?(instance['stateReason'][aliased_key])}
            else
              aliased_key = aliases[filter_key]
              instance_set = instance_set.reject {|instance| ![*filter_value].include?(instance[aliased_key])}
            end
          end

          response.status = 200
          reservation_set = {}

          instance_set.each do |instance|
            case instance['instanceState']['name']
            when 'pending'
              if Time.now - instance['launchTime'] > Fog::Mock.delay
                instance['ipAddress']         = Fog::AWS::Mock.ip_address
                instance['dnsName']           = Fog::AWS::Mock.dns_name_for(instance['ipAddress'])
                instance['privateIpAddress']  = Fog::AWS::Mock.ip_address
                instance['privateDnsName']    = Fog::AWS::Mock.private_dns_name_for(instance['privateIpAddress'])
                instance['instanceState']     = { 'code' => 16, 'name' => 'running' }
              end
            when 'rebooting'
              instance['instanceState'] = { 'code' => 16, 'name' => 'running' }
            when 'shutting-down'
              if Time.now - @data[:deleted_at][instance['instanceId']] > Fog::Mock.delay * 2
                @data[:deleted_at].delete(instance['instanceId'])
                @data[:instances].delete(instance['instanceId'])
              elsif Time.now - @data[:deleted_at][instance['instanceId']] > Fog::Mock.delay
                instance['instanceState'] = { 'code' => 48, 'name' => 'terminating' }
              end
            when 'terminating'
              if Time.now - @data[:deleted_at][instance['instanceId']] > Fog::Mock.delay
                @data[:deleted_at].delete(instance['instanceId'])
                @data[:instances].delete(instance['instanceId'])
              end
            end

            if @data[:instances][instance['instanceId']]

              reservation_set[instance['reservationId']] ||= {
                'groupSet'      => instance['groupSet'],
                'instancesSet'  => [],
                'ownerId'       => instance['ownerId'],
                'reservationId' => instance['reservationId']
              }
              reservation_set[instance['reservationId']]['instancesSet'] << instance.reject{|key,value| !['amiLaunchIndex', 'architecture', 'blockDeviceMapping', 'clientToken', 'dnsName', 'imageId', 'instanceId', 'instanceState', 'instanceType', 'ipAddress', 'kernelId', 'keyName', 'launchTime', 'monitoring', 'placement', 'privateDnsName', 'privateIpAddress', 'productCodes', 'ramdiskId', 'reason', 'rootDeviceType', 'stateReason', 'tagSet'].include?(key)}
            end
          end

          response.body = {
            'requestId'       => Fog::AWS::Mock.request_id,
            'reservationSet' => reservation_set.values
          }
          response
        end

      end
    end
  end
end
