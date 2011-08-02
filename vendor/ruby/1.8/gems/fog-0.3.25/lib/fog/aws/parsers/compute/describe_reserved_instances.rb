module Fog
  module Parsers
    module AWS
      module Compute

        class DescribeReservedInstances < Fog::Parsers::Base

          def reset
            @reserved_instance = {}
            @response = { 'reservedInstancesSet' => [] }
          end

          def end_element(name)
            case name
            when 'availabilityZone', 'instanceType', 'productDescription', 'reservedInstancesId', 'state'
              @reserved_instance[name] = @value
            when 'duration', 'instanceCount'
              @reserved_instance[name] = @value.to_i
            when 'fixedPrice', 'usagePrice'
              @reserved_instance[name] = @value.to_f
            when 'item'
              @response['reservedInstancesSet'] << @reserved_instance
              @reserved_instance = {}
            when 'requestId'
              @response[name] = @value
            when 'start'
              @response[name] = Time.parse(@value)
            end
          end

        end

      end
    end
  end
end
