module Fog
  class Vcloud
    module Terremark
      class Ecloud

        class Real
          basic_request :get_public_ips
        end

        class Mock
          #
          # Based off of:
          # http://support.theenterprisecloud.com/kb/default.asp?id=577&Lang=1&SID=
          #

          def get_public_ips(public_ips_uri)
            public_ips_uri = ensure_unparsed(public_ips_uri)

            if public_ip_collection = mock_data.public_ip_collection_from_href(public_ips_uri)
              xml = Builder::XmlMarkup.new
              mock_it 200,
                xml.PublicIPAddresses {
                  public_ip_collection.items.each do |ip|
                    xml.PublicIPAddress {
                      xml.Id ip.object_id
                      xml.Href ip.href
                      xml.Name ip.name
                    }
                  end
                }, { 'Content-Type' => 'application/vnd.tmrk.ecloud.publicIpsList+xml'}
            else
              mock_error 200, "401 Unauthorized"
            end
          end

        end
      end
    end
  end
end

