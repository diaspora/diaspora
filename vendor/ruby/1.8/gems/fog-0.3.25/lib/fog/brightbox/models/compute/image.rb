require 'fog/core/model'

module Fog
  module Brightbox
    class Compute

      class Image < Fog::Model

        identity :id

        attribute :url
        attribute :name
        attribute :status
        attribute :source
        attribute :source_type

        attribute :ancestor_id, :aliases => "ancestor", :squash => "id"
        attribute :owner_id, :aliases => "owner", :squash => "id"
        attribute :arch

        attribute :resource_type
        attribute :description
        attribute :public
        attribute :official
        attribute :virtual_size
        attribute :disk_size
        attribute :created_at

        def save
          requires :source, :arch
          options = {
            :source => source,
            :arch => arch,
            :name => name,
            :description => description
          }.delete_if {|k,v| v.nil? || v == "" }
          data = connection.create_image(options)
          merge_attributes(data)
          true
        end

        def destroy
          requires :identity
          connection.destroy_image(identity)
          true
        end

      end

    end
  end
end
