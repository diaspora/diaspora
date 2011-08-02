module Fog
  module Bluebox
    class Compute
      class Real

        # Get list of products
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Array>:
        #     * 'id'<~String> - UUID of the product
        #     * 'description'<~String> - Description of the product
        #     * 'cost'<~Decimal> - Hourly cost of the product
        def get_products
          request(
            :expects  => 200,
            :method   => 'GET',
            :path     => 'api/block_products.json'
          )
        end

      end

      class Mock

        def get_products
          Fog::Mock.not_implemented
        end

      end
    end
  end
end
