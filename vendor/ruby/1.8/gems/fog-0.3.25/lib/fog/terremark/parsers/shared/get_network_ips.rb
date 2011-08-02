module Fog
  module Parsers
    module Terremark
      module Shared

        class GetNetworkIps< Fog::Parsers::Base

          def reset
            @ip_address = {}
            @response = { 'IpAddresses' => [] }
          end

          def end_element(name)
            case name
            when 'Name', 'Status', 'Server'
              @ip_address[name.downcase] = @value
            when 'IpAddress'
              @response['IpAddresses'] << @ip_address
              @ip_address = {}
            end
          end

        end

      end
    end
  end
end

