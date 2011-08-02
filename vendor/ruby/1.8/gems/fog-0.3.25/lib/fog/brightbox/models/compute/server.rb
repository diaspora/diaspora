require 'fog/core/model'

module Fog
  module Brightbox
    class Compute

      class Server < Fog::Model

        identity  :id

        attribute :url
        attribute :name
        attribute :status
        attribute :hostname
        attribute :created_at, :type => :time
        attribute :deleted_at, :type => :time
        attribute :started_at, :type => :time
        attribute :user_data

        attribute :resource_type

        attribute :account_id, :aliases => "account", :squash => "id"
        attribute :image_id, :aliases => "image", :squash => "id"
        attribute :flavor_id, :aliases => "server_type", :squash => "id"
        attribute :zone_id, :aliases => "zone", :squash => "id"

        attribute :snapshots
        attribute :cloud_ips
        attribute :interfaces

        def snapshot
          requires :identity
          connection.snapshot_server(identity)
        end

        def reboot
          false
        end

        def start
          requires :identity
          connection.start_server(identity)
          true
        end

        def stop
          requires :identity
          connection.stop_server(identity)
          true
        end

        def shutdown
          requires :identity
          connection.shutdown_server(identity)
          true
        end

        def destroy
          requires :identity
          connection.destroy_server(identity)
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

        def ready?
          status == 'active'
        end

        def save
          requires :image_id
          options = {
            :image => image_id,
            :server_type => flavor_id,
            :name => name,
            :zone => zone_id,
            :user_data => user_data
          }.delete_if {|k,v| v.nil? || v == "" }
          data = connection.create_server(options)
          merge_attributes(data)
          true
        end
      end
    end
  end
end
