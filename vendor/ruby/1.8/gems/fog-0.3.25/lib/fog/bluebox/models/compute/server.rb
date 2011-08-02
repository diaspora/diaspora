require 'fog/core/model'

module Fog
  module Bluebox
    class Compute

      class BlockInstantiationError < StandardError; end

      class Server < Fog::Model
        extend Fog::Deprecation
        deprecate(:ssh_key, :public_key)
        deprecate(:ssh_key=, :public_key=)
        deprecate(:user, :username)
        deprecate(:user=, :username=)

        identity :id

        attribute :cpu
        attribute :description
        attribute :flavor_id,   :aliases => :product, :squash => 'id'
        attribute :hostname
        attribute :image_id
        attribute :ips
        attribute :memory
        attribute :status
        attribute :storage
        attribute :template

        attr_accessor :password
        attr_writer :private_key, :private_key_path, :public_key, :public_key_path, :username

        def initialize(attributes={})
          self.flavor_id ||= '94fd37a7-2606-47f7-84d5-9000deda52ae'
          super
        end

        def destroy
          requires :id
          connection.destroy_block(id)
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
          status == 'running'
        end

        def reboot(type = 'SOFT')
          requires :id
          connection.reboot_block(id, type)
          true
        end

        def save
          raise Fog::Errors::Error.new('Resaving an existing object may create a duplicate') if identity
          requires :flavor_id, :image_id
          options = if !password && !public_key
            raise(ArgumentError, "password or public_key is required for this operation")
          elsif public_key
            {'ssh_public_key' => public_key}
          elsif @password
            {'password' => password}
          end
          options['username'] = username
          data = connection.create_block(flavor_id, image_id, options)
          merge_attributes(data.body)
          true
        end

        def setup(credentials = {})
          requires :identity, :ips, :public_key, :username
          Fog::SSH.new(ips.first['address'], username, credentials).run([
            %{mkdir .ssh},
            %{echo "#{public_key}" >> ~/.ssh/authorized_keys},
            %{passwd -l root},
            %{echo "#{attributes.to_json}" >> ~/attributes.json}
          ])
        rescue Errno::ECONNREFUSED
          sleep(1)
          retry
        end

        def ssh(commands)
          requires :identity, :ips, :private_key, :username
          Fog::SSH.new(ips.first['address'], username, :key_data => [private_key]).run(commands)
        end

        def username
          @username ||= 'deploy'
        end

      end

    end
  end
end
