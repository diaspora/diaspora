module Fog
  module Bluebox
    class Compute
      class Real

        # Create a new block
        #
        # ==== Parameters
        # * product_id<~Integer> - Id of product to create block with
        # * template_id<~Integer> - Id of template to create block with
        # * options<~Hash>:
        #     * password<~String> - Password for block
        #   or
        #     * ssh_key<~String> - ssh public key
        #   * username<~String> - optional, defaults to deploy
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        # TODO
        def create_block(product_id, template_id, options = {})
          request(
            :expects  => 200,
            :method   => 'POST',
            :path     => '/api/blocks.json',
            :query    => {'product' => product_id, 'template' => template_id}.merge!(options)
          )
        end

      end

      class Mock

        def create_block(product_id, template_id, options = {})
          Fog::Mock.not_implemented
        end

      end
    end
  end
end
