module Fog
  class Vcloud
    module Terremark
      class Ecloud

        class Real
          basic_request :power_off, 202, 'POST'
        end

        class Mock
          def power_off(vapp_uri)
            if vapp = mock_data.virtual_machine_from_href(vapp_uri)
              vapp.power_off!

              builder = Builder::XmlMarkup.new
              mock_it 200, builder.Task(xmlns)
            else
              mock_error 200, "401 Unauthorized"
            end
          end
        end
      end
    end
  end
end
