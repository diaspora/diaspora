module Fog
  class Vcloud
    module Terremark
      class Ecloud

        class Real
          basic_request :delete_vapp, 202, "DELETE"
        end

        class Mock
          def delete_vapp(vapp_uri)
            if virtual_machine = mock_data.virtual_machine_from_href(vapp_uri)
              vdc = virtual_machine._parent

              if vdc.internet_service_collection.items.detect {|is| is.node_collection.items.any? {|isn| isn.ip_address == virtual_machine.ip } } ||
                  virtual_machine.status != 2
                mock_it 202, '', {}
              else
                vdc.virtual_machines.delete(virtual_machine)
                mock_it 202, '', { "Location" => mock_data.base_url + "/some_tasks/1234" }
              end
            else
              mock_error 200, "401 Unauthorized"
            end
          end
        end
      end
    end
  end
end

