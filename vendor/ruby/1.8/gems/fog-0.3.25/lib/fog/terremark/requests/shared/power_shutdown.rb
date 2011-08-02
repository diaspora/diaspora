module Fog
  module Terremark
    module Shared
      module Real

        # Shutdown a vapp
        #
        # ==== Parameters
        # * vapp_id<~Integer> - Id of vapp to shutdown
        #
        # ==== Returns
        # Nothing
        def power_shutdown(vapp_id)
          request(
            :expects  => 204,
            :method   => 'POST',
            :path     => "vApp/#{vapp_id}/power/action/shutdown"
          )
        end

      end

      module Mock

        def power_shutdown(vapp_id)
          Fog::Mock.not_implemented
        end

      end
    end
  end
end
