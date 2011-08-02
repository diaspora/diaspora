require 'fog/core/collection'
require 'fog/aws/models/compute/image'

module Fog
  module AWS
    class Compute

      class Images < Fog::Collection

        attribute :filters

        model Fog::AWS::Compute::Image

        def initialize(attributes)
          self.filters ||= {}
          super
        end

        def all(filters = @filters)
          self.filters = filters
          data = connection.describe_images(filters).body
          load(data['imagesSet'])
        end

        def get(image_id)
          if image_id
            self.class.new(:connection => connection).all('image-id' => image_id).first
          end
        end
      end

    end
  end
end
