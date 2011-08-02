module Fog
  class Vcloud
    module Terremark
      class Ecloud

        class Real
          basic_request :get_firewall_acl
        end

        class Mock
          def get_firewall_acl(firewall_acl_uri)
            Fog::Mock.not_implemented
          end
        end
      end
    end
  end
end
