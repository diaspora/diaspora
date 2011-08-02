module Fog
  class Vcloud
    module Terremark
      class Ecloud

        class Real
          basic_request :get_public_ip
        end

        class Mock
          #
          #Based off of:
          #http://support.theenterprisecloud.com/kb/default.asp?id=567&Lang=1&SID=
          #

          def get_public_ip(public_ip_uri)
            public_ip_uri = ensure_unparsed(public_ip_uri)

            if public_ip = mock_data.public_ip_from_href(public_ip_uri)
              xml = Builder::XmlMarkup.new
              mock_it 200,
                xml.PublicIp(:xmlns => "urn:tmrk:eCloudExtensions-2.0", :"xmlns:i" => "http://www.w3.org/2001/XMLSchema-instance") {
                  xml.Id public_ip.object_id
                  xml.Href public_ip.href
                  xml.Name public_ip.name
                }, { 'Content-Type' => 'application/vnd.tmrk.ecloud.publicIp+xml' }
            else
              mock_error 200, "401 Unauthorized"
            end
          end

        end
      end
    end
  end
end
