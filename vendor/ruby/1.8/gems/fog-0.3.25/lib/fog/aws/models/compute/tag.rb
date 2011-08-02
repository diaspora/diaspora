require 'fog/core/model'

module Fog
  module AWS
    class Compute

      class Tag < Fog::Model

        identity  :key

        attribute :value
        attribute :resource_id,           :aliases => 'resourceId'
        attribute :resource_type,         :aliases => 'resourceType'        

        def initialize(attributes = {})
          super
        end

        def destroy
          requires :key, :resource_id
          connection.delete_tags(resource_id, key)
          true
        end

        def save
          requires :key, :resource_id
          connection.create_tags(resource_id, key => value)
          true
        end

        private

      end
    end
  end
end
