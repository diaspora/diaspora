module Fog
  class Vcloud
    module Terremark
      class Ecloud

        class Real
          basic_request :get_customization_options
        end

        class Mock
          def get_customization_options(options_uri)
            builder = Builder::XmlMarkup.new
            xml = builder.CustomizationParameters(xmlns) do
              builder.CustomizeNetwork "true"
              builder.CustomizePassword "false"
            end

            mock_it 200, xml, "Content-Type" => "application/vnd.tmrk.ecloud.catalogItemCustomizationParameters+xml"
          end
        end
      end
    end
  end
end
