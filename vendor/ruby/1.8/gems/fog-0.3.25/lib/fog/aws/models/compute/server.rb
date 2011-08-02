require 'fog/core/model'

module Fog
  module AWS
    class Compute

      class Server < Fog::Model

        identity  :id,                    :aliases => 'instanceId'

        attr_accessor :architecture
        attribute :ami_launch_index,      :aliases => 'amiLaunchIndex'
        attribute :availability_zone,     :aliases => ['availabilityZone', 'placement'], :squash => 'availabilityZone'
        attribute :block_device_mapping,  :aliases => 'blockDeviceMapping'
        attribute :client_token,          :aliases => 'clientToken'
        attribute :dns_name,              :aliases => 'dnsName'
        attribute :groups
        attribute :flavor_id,             :aliases => 'instanceType'
        attribute :image_id,              :aliases => 'imageId'
        attr_accessor :instance_initiated_shutdown_behavior
        attribute :ip_address,            :aliases => 'ipAddress'
        attribute :kernel_id,             :aliases => 'kernelId'
        attribute :key_name,              :aliases => 'keyName'
        attribute :created_at,            :aliases => 'launchTime'
        attribute :monitoring,            :squash => 'state'
        attribute :product_codes,         :aliases => 'productCodes'
        attribute :private_dns_name,      :aliases => 'privateDnsName'
        attribute :private_ip_address,    :aliases => 'privateIpAddress'
        attribute :ramdisk_id,            :aliases => 'ramdiskId'
        attribute :reason
        attribute :root_device_name,      :aliases => 'rootDeviceName'
        attribute :root_device_type,      :aliases => 'rootDeviceType'
        attribute :state,                 :aliases => 'instanceState', :squash => 'name'
        attribute :state_reason,          :aliases => 'stateReason'
        attribute :subnet_id,             :aliases => 'subnetId'
        attribute :tags,                  :aliases => 'tagSet'
        attribute :user_data

        attr_accessor :password
        attr_writer   :private_key, :private_key_path, :public_key, :public_key_path, :username

        def initialize(attributes={})
          self.groups ||= ["default"] unless attributes[:subnet_id]
          self.flavor_id ||= 'm1.small'
          super
        end

        def addresses
          requires :id

          connection.addresses(:server => self)
        end

        def console_output
          requires :id

          connection.get_console_output(id)
        end

        def destroy
          requires :id

          connection.terminate_instances(id)
          true
        end

        remove_method :flavor_id
        def flavor_id
          @flavor && @flavor.id || attributes[:flavor_id]
        end

        def flavor=(new_flavor)
          @flavor = new_flavor
        end

        def flavor
          @flavor ||= connection.flavors.all.detect {|flavor| flavor.id == flavor_id}
        end

        def key_pair
          requires :key_name

          connection.keypairs.all(key_name).first
        end

        def key_pair=(new_keypair)
          key_name = new_keypair && new_keypair.name
        end

        def private_key_path
          @private_key_path ||= Fog.credentials[:private_key_path]
          @private_key_path &&= File.expand_path(@private_key_path)
        end

        def private_key
          @private_key ||= private_key_path && File.read(private_key_path)
        end

        def public_key_path
          @public_key_path ||= Fog.credentials[:public_key_path]
          @public_key_path &&= File.expand_path(@public_key_path)
        end

        def public_key
          @public_key ||= public_key_path && File.read(public_key_path)
        end

        def ready?
          state == 'running'
        end

        def reboot
          requires :id
          connection.reboot_instances(id)
          true
        end

        def save
          raise Fog::Errors::Error.new('Resaving an existing object may create a duplicate') if identity
          requires :image_id

          options = {
            'BlockDeviceMapping'          => block_device_mapping,
            'ClientToken'                 => client_token,
            'InstanceInitiatedShutdownBehavior' => instance_initiated_shutdown_behavior,
            'InstanceType'                => flavor_id,
            'KernelId'                    => kernel_id,
            'KeyName'                     => key_name,
            'Monitoring.Enabled'          => monitoring,
            'Placement.AvailabilityZone'  => availability_zone,
            'RamdiskId'                   => ramdisk_id,
            'SecurityGroup'               => groups,
            'SubnetId'                    => subnet_id,
            'UserData'                    => user_data
          }
          options.delete_if {|key, value| value.nil?}

          # If subnet is defined we are working on a virtual private cloud.
          # subnet & security group cannot co-exist. I wish VPC just ignored
          # the security group parameter instead, it would be much easier!
          if subnet_id
            options.delete('SecurityGroup')
          else
            options.delete('SubnetId')
          end

          data = connection.run_instances(image_id, 1, 1, options)
          merge_attributes(data.body['instancesSet'].first)
          true
        end

        def setup(credentials = {})
          requires :identity, :ip_address, :username
          sleep(10) # takes a bit before EC2 instances will play nice
          commands = [
            %{mkdir .ssh},
            %{passwd -l root},
            %{echo "#{attributes.to_json}" >> ~/attributes.json}
          ]
          if public_key
            commands << %{echo "#{public_key}" >> ~/.ssh/authorized_keys}
          end
          Fog::SSH.new(ip_address, username, credentials).run(commands)
        rescue Errno::ECONNREFUSED => e
          sleep(1)
          retry
        end

        def ssh(commands)
          requires :identity, :ip_address, :private_key, :username
          Fog::SSH.new(ip_address, username, :key_data => [private_key]).run(commands)
        end

        def start
          requires :id
          connection.start_instances(id)
          true
        end

        def stop
          requires :id
          connection.stop_instances(id)
          true
        end

        def username
          @username ||= 'root'
        end

        def volumes
          requires :id
          connection.volumes(:server => self)
        end

      end

    end
  end
end
