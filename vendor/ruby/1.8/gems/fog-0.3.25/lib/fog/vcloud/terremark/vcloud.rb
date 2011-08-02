module Fog
  class Vcloud
    module Terremark
      class Vcloud < Fog::Vcloud
        request_path 'fog/vcloud/terremark/vcloud/requests'
        request :get_vdc

        class Real < Fog::Vcloud::Real

          def supporting_versions
            ["0.8", "0.8a-ext1.6"]
          end

        end

        class Mock < Fog::Vcloud::Mock
        end

      end
    end
  end
end
