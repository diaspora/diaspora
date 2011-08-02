module Fog
  class Vcloud
    module Terremark
      class Ecloud

        class Real
          basic_request :power_shutdown, 204, 'POST'
        end

        class Mock
          def power_shutdown(shutdown_uri)
            Fog::Mock.not_implemented
          end
        end
      end
    end
  end
end
