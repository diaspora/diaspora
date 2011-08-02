module Fog
  module Parsers
    module Terremark
      module Shared

        class GetVdc < Fog::Parsers::Base

          def reset
            @in_storage_capacity = false
            @in_cpu = false
            @in_memory = false
            @in_instantiated_vms_quota = false
            @in_deployed_vms_quota = false
            @response = { 
              'links' => [],
              'AvailableNetworks' => [],
              'ComputeCapacity'   => {
                'Cpu' => {},
                'DeployedVmsQuota' => {},
                'InstantiatedVmsQuota' => {},
                'Memory' => {}
              },
              'StorageCapacity'  => {},
              'ResourceEntities' => []
            }
          end

          def start_element(name, attributes)
            super
            case name
            when 'Cpu'
              @in_cpu = true
            when 'DeployedVmsQuota'
              @in_deployed_vms_quota = true
            when 'InstantiatedVmsQuota'
              @in_instantiated_vms_quota = true
            when 'Link'
              link = {}
              until attributes.empty?
                link[attributes.shift] = attributes.shift
              end
              @response['links'] << link
            when 'Memory'
              @in_memory = true
            when 'Network'
              network = {}
              until attributes.empty?
                network[attributes.shift] = attributes.shift
              end
              @response['AvailableNetworks'] << network
            when 'ResourceEntity'
              resource_entity = {}
              until attributes.empty?
                resource_entity[attributes.shift] = attributes.shift
              end
              @response['ResourceEntities'] << resource_entity
            when 'StorageCapacity'
              @in_storage_capacity = true
            when 'Vdc'
              vdc = {}
              until attributes.empty?
                if attributes.first.is_a?(Array)
                  attribute = attributes.shift
                  vdc[attribute.first] = attribute.last
                else
                  vdc[attributes.shift] = attributes.shift
                end
              end
              @response['href'] = vdc['href']
              @response['name'] = vdc['name']
            end
          end

          def end_element(name)
            case name
            when 'Allocated', 'Limit', 'Units', 'Used'
              if @in_cpu
                @response['ComputeCapacity']['Cpu'][name] = @value
              elsif @in_deployed_vms_quota
                @response['ComputeCapacity']['DeployedVmsQuota'][name] = @value
              elsif @in_instantiated_vms_quota
                @response['ComputeCapacity']['InstantiatedVmsQuota'][name] = @value
              elsif @in_memory
                @response['ComputeCapacity']['Memory'][name] = @value
              elsif @in_storage_capacity
                @response['StorageCapacity'][name] = @value
              end
            when 'Cpu'
              @in_cpu = false
            when 'DeployedVmsQuota'
              @in_deployed_vms_quota = false
            when 'InstantiatedVmsQuota'
              @in_instantiated_vms_quota = false
            when 'Memory'
              @in_memory = false
            when 'StorageCapacity'
              @in_storage_capacity = false
            when 'Type'
              @response[name] = @value
            end
          end

        end

      end
    end
  end
end
