module Fog
  module Parsers
    module AWS
      module Compute

        class DescribeSecurityGroups < Fog::Parsers::Base

          def reset
            @group = {}
            @ip_permission = { 'groups' => [], 'ipRanges' => []}
            @ip_range = {}
            @security_group = { 'ipPermissions' => [] }
            @response = { 'securityGroupInfo' => [] }
          end

          def start_element(name, attrs = [])
            super
            case name
            when 'groups'
              @in_groups = true
            when 'ipPermissions'
              @in_ip_permissions = true
            when 'ipRanges'
              @in_ip_ranges = true
            end
          end

          def end_element(name)
            case name
            when 'cidrIp'
              @ip_range[name] = @value
            when 'fromPort', 'toPort'
              @ip_permission[name] = @value.to_i
            when 'groups'
              @in_groups = false
            when 'groupDescription', 'ownerId'
              @security_group[name] = @value
            when 'groupName'
              if @in_groups
                @group[name] = @value
              else
                @security_group[name] = @value
              end
            when 'ipPermissions'
              @in_ip_permissions = false
            when 'ipProtocol'
              @ip_permission[name] = @value
            when 'ipRanges'
              @in_ip_ranges = false
            when 'item'
              if @in_groups
                @ip_permission['groups'] << @group
                @group = {}
              elsif @in_ip_ranges
                @ip_permission['ipRanges'] << @ip_range
                @ip_range = {}
              elsif @in_ip_permissions
                @security_group['ipPermissions'] << @ip_permission
                @ip_permission = { 'groups' => [], 'ipRanges' => []}
               else
                @response['securityGroupInfo'] << @security_group
                @security_group = { 'ipPermissions' => [] }
              end
            when 'requestId'
              @response[name] = @value
            when 'userId'
              @group[name] = @value
            end
          end

        end

      end
    end
  end
end
