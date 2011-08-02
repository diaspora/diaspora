require 'fog/core/model'

module Fog
  module Rackspace
    class Compute

      class Server < Fog::Model

        identity :id

        attribute :addresses
        attribute :flavor_id,   :aliases => 'flavorId'
        attribute :host_id,     :aliases => 'hostId'
        attribute :image_id,    :aliases => 'imageId'
        attribute :metadata
        attribute :name
        attribute :personality
        attribute :progress
        attribute :status

        attr_reader :password
        attr_writer :private_key, :private_key_path, :public_key, :public_key_path, :username

        def initialize(attributes={})
          self.flavor_id ||= 1
          super
        end

        def destroy
          requires :id
          connection.delete_server(id)
          true
        end

        def flavor
          requires :flavor_id
          connection.flavors.get(flavor_id)
        end

        def image
          requires :image_id
          connection.images.get(image_id)
        end

        def images
          requires :id
          connection.images(:server => self)
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
          status == 'ACTIVE'
        end

        def reboot(type = 'SOFT')
          requires :id
          connection.reboot_server(id, type)
          true
        end

        def save
          raise Fog::Errors::Error.new('Resaving an existing object may create a duplicate') if identity
          requires :flavor_id, :image_id, :name
          options = {
            'metadata'    => metadata,
            'name'        => name,
            'personality' => personality
          }
          options = options.reject {|key, value| value.nil?}
          data = connection.create_server(flavor_id, image_id, options)
          merge_attributes(data.body['server'])
          true
        end

        def setup(credentials = {})
          requires :addresses, :identity, :public_key, :username
          Fog::SSH.new(addresses['public'].first, username, credentials).run([
            %{mkdir .ssh},
            %{echo "#{public_key}" >> ~/.ssh/authorized_keys},
            %{passwd -l root},
            %{echo "#{attributes.to_json}" >> ~/attributes.json},
            %{echo "#{metadata.to_json}" >> ~/metadata.json}
          ])
        rescue Errno::ECONNREFUSED
          sleep(1)
          retry
        end

        def ssh(commands)
          requires :addresses, :identity, :private_key, :username
          Fog::SSH.new(addresses['public'].first, username, :key_data => [private_key]).run(commands)
        end

        def username
          @username ||= 'root'
        end

        private

        def adminPass=(new_admin_pass)
          @password = new_admin_pass
        end

      end

    end
  end

end
