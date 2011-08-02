require 'fog/core/model'

module Fog
  module Brightbox
    class Compute

      class Flavor < Fog::Model

        identity :id

        attribute :url
        attribute :name
        attribute :status

        attribute :handle

        attribute :bits
        attribute :cores
        attribute :disk, :aliases => "disk_size"
        attribute :ram

        attribute :resource_type
        attribute :description

        def bits
          0 # This is actually based on the Image type used. 32bit or 64bit Images are supported
        end

      end

    end
  end
end
