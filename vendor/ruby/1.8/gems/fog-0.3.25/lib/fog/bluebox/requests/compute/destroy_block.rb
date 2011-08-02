module Fog
  module Bluebox
    class Compute
      class Real

        # Destroy a block
        #
        # ==== Parameters
        # * block_id<~Integer> - Id of block to destroy
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        # TODO
        def destroy_block(block_id)
          request(
            :expects  => 200,
            :method   => 'DELETE',
            :path     => "api/blocks/#{block_id}.json"
          )
        end

      end

      class Mock

        def destroy_block(block_id)
          Fog::Mock.not_implemented
        end

      end
    end
  end
end
