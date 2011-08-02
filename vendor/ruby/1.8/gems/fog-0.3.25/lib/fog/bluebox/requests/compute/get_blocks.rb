module Fog
  module Bluebox
    class Compute
      class Real

        # Get list of blocks
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Array>:
        #     * 'ips'<~Array> - Ip addresses for the block
        #     * 'id'<~String> - Id of the block
        #     * 'storage'<~Integer> - Disk space quota for the block
        #     * 'memory'<~Integer> - RAM quota for the block
        #     * 'cpu'<~Float> - The fractional CPU quota for this block
        #     * 'hostname'<~String> - The hostname for the block
        def get_blocks
          request(
            :expects  => 200,
            :method   => 'GET',
            :path     => 'api/blocks.json'
          )
        end

      end

      class Mock

        def get_blocks
          Fog::Mock.not_implemented
        end

      end
    end
  end
end
