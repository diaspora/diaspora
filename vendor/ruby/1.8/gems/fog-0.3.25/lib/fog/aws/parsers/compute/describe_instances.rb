module Fog
  module Parsers
    module AWS
      module Compute

        class DescribeInstances < Fog::Parsers::Base

          def reset
            @block_device_mapping = {}
            @instance = { 'blockDeviceMapping' => [], 'instanceState' => {}, 'monitoring' => {}, 'placement' => {}, 'productCodes' => [], 'stateReason' => {}, 'tagSet' => {} }
            @reservation = { 'groupSet' => [], 'instancesSet' => [] }
            @response = { 'reservationSet' => [] }
            @tag = {}
          end

          def start_element(name, attrs = [])
            super
            case name
            when 'blockDeviceMapping'
              @in_block_device_mapping = true
            when'groupSet', 'productCodes'
              @in_subset = true
            when 'instancesSet'
              @in_instances_set = true
            when 'instanceState'
              @in_instance_state = true
            when 'stateReason'
              @in_state_reason = true
            when 'tagSet'
              @in_tag_set = true
            end
          end

          def end_element(name)
            case name
            when 'amiLaunchIndex'
              @instance[name] = @value.to_i
            when 'availabilityZone'
              @instance['placement'][name] = @value
            when 'architecture', 'clientToken', 'dnsName', 'imageId',
                  'instanceId', 'instanceType', 'ipAddress', 'kernelId',
                  'keyName', 'privateDnsName', 'privateIpAddress', 'ramdiskId',
                  'reason', 'rootDeviceType'
              @instance[name] = @value
            when 'attachTime'
              @block_device_mapping[name] = Time.parse(@value)
            when 'blockDeviceMapping'
              @in_block_device_mapping = false
            when 'code'
              if @in_instance_state
                @instance['instanceState'][name] = @value.to_i
              elsif @in_state_reason
                @instance['stateReason'][name] = @value.to_i
              end
            when 'deleteOnTermination'
              if @value == 'true'
                @block_device_mapping[name] = true
              else
                @block_device_mapping[name] = false
              end
            when 'deviceName', 'status', 'volumeId'
              @block_device_mapping[name] = @value
            when 'groupId'
              @reservation['groupSet'] << @value
            when 'groupSet', 'productCodes'
              @in_subset = false
            when 'instancesSet'
              @in_instances_set = false
            when 'instanceState'
              @in_instance_state = false
            when 'item'
              if @in_block_device_mapping
                @instance['blockDeviceMapping'] << @block_device_mapping
                @block_device_mapping = {}
              elsif @in_tag_set
                @instance['tagSet'][@tag['key']] = @tag['value']
                @tag = {}
              elsif @in_instances_set
                @reservation['instancesSet'] << @instance
                @instance = { 'blockDeviceMapping' => [], 'instanceState' => {}, 'monitoring' => {}, 'placement' => {}, 'productCodes' => [], 'stateReason' => {}, 'tagSet' => {} }
              elsif !@in_subset
                @response['reservationSet'] << @reservation
                @reservation = { 'groupSet' => [], 'instancesSet' => [] }
              end
            when 'key', 'value'
              @tag[name] = @value
            when 'launchTime'
              @instance[name] = Time.parse(@value)
            when 'name'
              if @in_instance_state
                @instance['instanceState'][name] = @value
              elsif @in_state_reason
                @instance['stateReason'][name] = @value
              end
            when 'ownerId', 'reservationId'
              @reservation[name] = @value
            when 'requestId'
              @response[name] = @value
            when 'productCode'
              @instance['productCodes'] << @value
            when 'state'
              if @value == 'true'
                @instance['monitoring'][name] = true
              else
                @instance['monitoring'][name] = false
              end
            when 'stateReason'
              @in_state_reason = false
            when 'tagSet'
              @in_tag_set = false
            end
          end

        end

      end
    end
  end
end
