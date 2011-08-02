module Fog
  module AWS
    class Compute
      class Real

        require 'fog/aws/parsers/compute/run_instances'

        # Launch specified instances
        #
        # ==== Parameters
        # * image_id<~String> - Id of machine image to load on instances
        # * min_count<~Integer> - Minimum number of instances to launch. If this
        #   exceeds the count of available instances, no instances will be
        #   launched.  Must be between 1 and maximum allowed for your account
        #   (by default the maximum for an account is 20)
        # * max_count<~Integer> - Maximum number of instances to launch. If this
        #   exceeds the number of available instances, the largest possible
        #   number of instances above min_count will be launched instead. Must
        #   be between 1 and maximum allowed for you account
        #   (by default the maximum for an account is 20)
        # * options<~Hash>:
        #   * 'Placement.AvailabilityZone'<~String> - Placement constraint for instances
        #   * 'BlockDeviceMapping'<~Array>: array of hashes
        #     * 'DeviceName'<~String> - where the volume will be exposed to instance
        #     * 'VirtualName'<~String> - volume virtual device name
        #     * 'Ebs.SnapshotId'<~String> - id of snapshot to boot volume from
        #     * 'Ebs.VolumeSize'<~String> - size of volume in GiBs required unless snapshot is specified
        #     * 'Ebs.DeleteOnTermination'<~String> - specifies whether or not to delete the volume on instance termination
        #   * 'ClientToken'<~String> - unique case-sensitive token for ensuring idempotency
        #   * 'SecurityGroup'<~Array> or <~String> - Name of security group(s) for instances (you must omit this parameter if using Virtual Private Clouds)
        #   * 'InstanceInitiatedShutdownBehaviour'<~String> - specifies whether volumes are stopped or terminated when instance is shutdown, in [stop, terminate]
        #   * 'InstanceType'<~String> - Type of instance to boot. Valid options
        #     in ['m1.small', 'm1.large', 'm1.xlarge', 'c1.medium', 'c1.xlarge', 'm2.2xlarge', 'm2.4xlarge']
        #     default is 'm1.small'
        #   * 'KernelId'<~String> - Id of kernel with which to launch
        #   * 'KeyName'<~String> - Name of a keypair to add to booting instances
        #   * 'Monitoring.Enabled'<~Boolean> - Enables monitoring, defaults to
        #     disabled
        #   * 'RamdiskId'<~String> - Id of ramdisk with which to launch
        #   * 'UserData'<~String> -  Additional data to provide to booting instances
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'groupSet'<~Array>: groups the instances are members in
        #       * 'groupName'<~String> - Name of group
        #     * 'instancesSet'<~Array>: returned instances
        #       * instance<~Hash>:
        #         * 'amiLaunchIndex'<~Integer> - reference to instance in launch group
        #         * 'architecture'<~String> - architecture of image in [i386, x86_64]
        #         * 'blockDeviceMapping'<~Array>
        #           * 'attachTime'<~Time> - time of volume attachment
        #           * 'deleteOnTermination'<~Boolean> - whether or not to delete volume on termination
        #           * 'deviceName'<~String> - specifies how volume is exposed to instance
        #           * 'status'<~String> - status of attached volume
        #           * 'volumeId'<~String> - Id of attached volume
        #         * 'dnsName'<~String> - public dns name, blank until instance is running
        #         * 'imageId'<~String> - image id of ami used to launch instance
        #         * 'instanceId'<~String> - id of the instance
        #         * 'instanceState'<~Hash>:
        #           * 'code'<~Integer> - current status code
        #           * 'name'<~String> - current status name
        #         * 'instanceType'<~String> - type of instance
        #         * 'ipAddress'<~String> - public ip address assigned to instance
        #         * 'kernelId'<~String> - Id of kernel used to launch instance
        #         * 'keyName'<~String> - name of key used launch instances or blank
        #         * 'launchTime'<~Time> - time instance was launched
        #         * 'monitoring'<~Hash>:
        #           * 'state'<~Boolean - state of monitoring
        #         * 'placement'<~Hash>:
        #           * 'availabilityZone'<~String> - Availability zone of the instance
        #         * 'privateDnsName'<~String> - private dns name, blank until instance is running
        #         * 'privateIpAddress'<~String> - private ip address assigned to instance
        #         * 'productCodes'<~Array> - Product codes for the instance
        #         * 'ramdiskId'<~String> - Id of ramdisk used to launch instance
        #         * 'reason'<~String> - reason for most recent state transition, or blank
        #         * 'rootDeviceName'<~String> - specifies how the root device is exposed to the instance
        #         * 'rootDeviceType'<~String> - root device type used by AMI in [ebs, instance-store]
        #     * 'ownerId'<~String> - Id of owner
        #     * 'requestId'<~String> - Id of request
        #     * 'reservationId'<~String> - Id of reservation
        def run_instances(image_id, min_count, max_count, options = {})
          if block_device_mapping = options.delete('BlockDeviceMapping')
            block_device_mapping.each_with_index do |mapping, index|
              for key, value in mapping
                options.merge!({ format("BlockDeviceMapping.%d.#{key}", index) => value })
              end
            end
          end
          if security_groups = options.delete('SecurityGroup')
            options.merge!(AWS.indexed_param('SecurityGroup', [*security_groups]))
          end
          if options['UserData']
            options['UserData'] = Base64.encode64(options['UserData'])
          end

          idempotent = !(options['ClientToken'].nil? || options['ClientToken'].empty?)

          request({
            'Action'    => 'RunInstances',
            'ImageId'   => image_id,
            'MinCount'  => min_count,
            'MaxCount'  => max_count,
            :idempotent => idempotent,
            :parser     => Fog::Parsers::AWS::Compute::RunInstances.new
          }.merge!(options))
        end

      end

      class Mock

        def run_instances(image_id, min_count, max_count, options = {})
          response = Excon::Response.new
          response.status = 200

          group_set = [ (options['GroupId'] || 'default') ]
          instances_set = []
          reservation_id = Fog::AWS::Mock.reservation_id

          min_count.times do |i|
            instance_id = Fog::AWS::Mock.instance_id
            instance = {
              'amiLaunchIndex'      => i,
              'blockDeviceMapping'  => [],
              'clientToken'         => options['clientToken'],
              'dnsName'             => nil,
              'imageId'             => image_id,
              'instanceId'          => instance_id,
              'instanceState'       => { 'code' => 0, 'name' => 'pending' },
              'instanceType'        => options['InstanceType'] || 'm1.small',
              'kernelId'            => options['KernelId'] || Fog::AWS::Mock.kernel_id,
              # 'keyName'             => options['KeyName'],
              'launchTime'          => Time.now,
              'monitoring'          => { 'state' => options['Monitoring.Enabled'] || false },
              'placement'           => { 'availabilityZone' => options['Placement.AvailabilityZone'] || Fog::AWS::Mock.availability_zone },
              'privateDnsName'      => nil,
              'productCodes'        => [],
              'ramdiskId'           => options['RamdiskId'] || Fog::AWS::Mock.ramdisk_id,
              'reason'              => nil,
              'rootDeviceType'      => 'instance-store'
            }
            instances_set << instance
            @data[:instances][instance_id] = instance.merge({
              'architecture'        => 'i386',
              'groupSet'            => group_set,
              'ownerId'             => @owner_id,
              'privateIpAddress'    => nil,
              'reservationId'       => reservation_id,
              'stateReason'         => {},
              'tagSet'              => {}
            })
          end
          response.body = {
            'groupSet'      => group_set,
            'instancesSet'  => instances_set,
            'ownerId'       => @owner_id,
            'requestId'     => Fog::AWS::Mock.request_id,
            'reservationId' => reservation_id
          }
          response
        end

      end
    end
  end
end
