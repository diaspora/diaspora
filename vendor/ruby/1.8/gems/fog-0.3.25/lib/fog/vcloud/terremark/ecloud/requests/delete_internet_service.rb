module Fog
  class Vcloud
    module Terremark
      class Ecloud

        class Real
          basic_request :delete_internet_service, 200, 'DELETE', {}, ""
        end

        class Mock
          def delete_internet_service(service_uri)
            if public_ip_internet_service = mock_data.public_ip_internet_service_from_href(service_uri)
              public_ip_internet_service._parent.items.delete(public_ip_internet_service)

              mock_it 200, '', { }
            else
              mock_error 200, "401 Unauthorized"
            end
          end
        end
      end
    end
  end
end

