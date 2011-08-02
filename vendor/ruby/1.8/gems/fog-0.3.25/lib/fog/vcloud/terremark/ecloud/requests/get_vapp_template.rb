module Fog
  class Vcloud
    module Terremark
      class Ecloud

        class Real
          basic_request :get_vapp_template
        end

        class Mock
          def get_vapp_template(templace_uri)
            Fog::Mock.not_implemented
          end
        end
      end
    end
  end
end
