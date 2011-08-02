require 'fog/core/collection'
require 'fog/bluebox/models/compute/flavor'

module Fog
  module Bluebox
    class Compute

      class Flavors < Fog::Collection

        model Fog::Bluebox::Compute::Flavor

        def all
          data = connection.get_products.body
          load(data)
        end

        def get(product_id)
          response = connection.get_product(product_id)
          new(response.body)
        rescue Fog::Bluebox::Compute::NotFound
          nil
        end

      end

    end
  end
end
