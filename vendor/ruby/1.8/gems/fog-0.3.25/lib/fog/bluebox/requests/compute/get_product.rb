module Fog
  module Bluebox
    class Compute
      class Real

        # Get details of a product
        #
        # ==== Parameters
        # * product_id<~Integer> - Id of flavor to lookup
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Array>:
        # TODO
        def get_product(product_id)
          request(
            :expects  => 200,
            :method   => 'GET',
            :path     => "api/block_products/#{product_id}.json"
          )
        end

      end

      class Mock

        def get_product(product_id)
          Fog::Mock.not_implemented
        end

      end
    end
  end
end
