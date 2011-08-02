module Fog
  module Terremark
    module Shared
      module Real

        require 'fog/terremark/parsers/shared/get_node_services'

        # Get a list of all internet services for a vdc
        #
        # ==== Parameters
        # * service_id<~Integer> - Id of internet service that we want a list of nodes for
         #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
       
        #       
        def get_node_services(service_id)
           request(
            :expects  => 200,
            :method   => 'GET',
            :parser   => Fog::Parsers::Terremark::Shared::GetNodeServices.new,
            :path     => "InternetServices/#{service_id}/nodes"
          )
        end

      end

      module Mock

        def get_node_services(vdc_id)
          Fog::Mock.not_implemented
        end

      end
    end
  end
end
