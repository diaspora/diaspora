require 'fog/core/collection'
require 'fog/bluebox/models/compute/image'

module Fog
  module Bluebox
    class Compute

      class Images < Fog::Collection

        model Fog::Bluebox::Compute::Image

        def all
          data = connection.get_templates.body
          load(data)
        end

        def get(template_id)
          response = connection.get_template(template_id)
          new(response.body)
        rescue Fog::Bluebox::Compute::NotFound
          nil
        end

      end

    end
  end
end
