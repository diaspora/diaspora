require 'fog/core/model'

module Fog
  module GoGrid
    class Compute

      class BlockInstantiationError < StandardError; end

      class Server < Fog::Model

        identity :id

        attribute :name
        attribute :image_id        # id or name
        attribute :ip
        attribute :memory       # server.ram
        attribute :state
        attribute :description  # Optional
        attribute :sandbox      # Optional. Default: False

        def initialize(attributes={})
          super
        end

        def destroy
          requires :id
          connection.grid_server_destroy(id)
          true
        end

        def image
          requires :image_id
          connection.grid_image_get(image_id)
        end

        def ready?
          @state == 'On'
        end

        def save
          raise Fog::Errors::Error.new('Resaving an existing object may create a duplicate') if identity
          requires :name, :image_id, :ip, :memory
          options['isSandbox'] = sandbox if sandbox
          options['server.ram'] = memory
          options['image'] = image_id
          data = connection.grid_server_add(name, image, ip, options)
          merge_attributes(data.body)
          true
        end

      end

    end

  end
end
