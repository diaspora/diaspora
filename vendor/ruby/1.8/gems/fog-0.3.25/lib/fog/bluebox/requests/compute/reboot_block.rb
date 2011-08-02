module Fog
  module Bluebox
    class Compute
      class Real

        # Reboot block
        #
        # ==== Parameters
        # * block_id<~String> - Id of block to reboot
        # * type<~String> - Type of reboot, must be in ['HARD', 'SOFT']
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        # TODO
        def reboot_block(block_id, type = 'SOFT')
          request(
            :expects  => 200,
            :method   => 'PUT',
            :path     => "api/blocks/#{block_id}/#{'soft_' if type == 'SOFT'}reboot.json"
          )
        end

      end

      class Mock

        def reboot_block(block_id, type = 'SOFT')
          Fog::Mock.not_implemented
        end

      end
    end
  end
end
