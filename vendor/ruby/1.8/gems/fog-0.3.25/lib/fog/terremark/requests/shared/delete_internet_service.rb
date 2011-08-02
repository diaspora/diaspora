module Fog
  module Terremark
    module Shared
      module Real

        # Destroy an internet service
        #
        # ==== Parameters
        # * internet_service_id<~Integer> - Id of service to destroy
        #
        def delete_internet_service(internet_service_id)
          request(
            :expects  => 200,
            :method   => 'DELETE',
            :path     => "InternetServices/#{internet_service_id}"
          )
        end

      end

      module Mock

        def delete_internet_service(internet_service_id)
          Fog::Mock.not_implemented
        end

      end
    end
  end
end
