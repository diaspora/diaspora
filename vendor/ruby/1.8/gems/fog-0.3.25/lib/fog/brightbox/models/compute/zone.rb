require 'fog/core/model'

module Fog
  module Brightbox
    class Compute

      class Zone < Fog::Model

        identity :id

        attribute :url
        attribute :handle
        attribute :status
        attribute :resource_type
        attribute :description

      end

    end
  end
end