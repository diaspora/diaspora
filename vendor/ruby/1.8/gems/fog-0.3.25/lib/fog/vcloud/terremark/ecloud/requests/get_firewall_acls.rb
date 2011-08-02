module Fog
  class Vcloud
    module Terremark
      class Ecloud

        class Real
          basic_request :get_firewall_acls
        end

        class Mock
          def get_firewall_acls(firewall_acls_uri)
            Fog::Mock.not_implemented
          end
        end
      end
    end
  end
end
