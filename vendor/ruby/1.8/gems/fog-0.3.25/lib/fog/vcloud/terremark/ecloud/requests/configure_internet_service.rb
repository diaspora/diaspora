module Fog
  class Vcloud
    module Terremark
      class Ecloud
        module Shared
          private

          def generate_internet_service_response(public_ip_internet_service)
            builder = Builder::XmlMarkup.new
            builder.InternetService(:"xmlns:i" => "http://www.w3.org/2001/XMLSchema-instance",
                                    :xmlns => "urn:tmrk:eCloudExtensions-2.3") {
              builder.Id(public_ip_internet_service.object_id)
              builder.Href(public_ip_internet_service.href)
              builder.Name(public_ip_internet_service.name)
              builder.Protocol(public_ip_internet_service.protocol)
              builder.Port(public_ip_internet_service.port)
              builder.Enabled(public_ip_internet_service.enabled)
              builder.Description(public_ip_internet_service.description)
              builder.Timeout(public_ip_internet_service.timeout)
              builder.RedirectURL(public_ip_internet_service.redirect_url)
              builder.PublicIpAddress {
                builder.Id(public_ip_internet_service._parent._parent.object_id)
                builder.Href(public_ip_internet_service._parent._parent.href)
                builder.Name(public_ip_internet_service._parent._parent.name)
              }
              if monitor = public_ip_internet_service.monitor
                generate_monitor_section(builder, public_ip_internet_service.monitor)
              end
            }
          end

          def validate_public_ip_address_data(ip_address_data)
            valid_opts = [:name, :href, :id]
            unless valid_opts.all? { |opt| ip_address_data.keys.include?(opt) }
              raise ArgumentError.new("Required Internet Service data missing: #{(valid_opts - ip_address_data.keys).map(&:inspect).join(", ")}")
            end
          end
        end

        class Real
          include Shared

          def configure_internet_service(internet_service_uri, service_data, ip_address_data)
            validate_internet_service_data(service_data, true)

            validate_public_ip_address_data(ip_address_data)

            if monitor = service_data[:monitor]
              validate_internet_service_monitor(monitor)
              ensure_monitor_defaults!(monitor)
            end

            request(
              :body     => generate_internet_service_response(service_data, ip_address_data),
              :expects  => 200,
              :headers  => {'Content-Type' => 'application/vnd.tmrk.ecloud.internetService+xml'},
              :method   => 'PUT',
              :uri      => internet_service_uri,
              :parse    => true
            )
          end

        end

        class Mock
          include Shared

          #
          # Based on
          # http://support.theenterprisecloud.com/kb/default.asp?id=583&Lang=1&SID=
          #

          def configure_internet_service(internet_service_uri, service_data, ip_address_data)
            validate_internet_service_data(service_data, true)

            validate_public_ip_address_data(ip_address_data)

            internet_service_uri = ensure_unparsed(internet_service_uri)

            xml = nil

            if public_ip_internet_service = mock_data.public_ip_internet_service_from_href(internet_service_uri)
              public_ip_internet_service.update(service_data.reject {|k, v| [:id, :href].include?(k) })
              xml = generate_internet_service_response(public_ip_internet_service)
            end

            if xml
              mock_it 200, xml, {'Content-Type' => 'application/vnd.tmrk.ecloud.internetService+xml'}
            else
              mock_error 200, "401 Unauthorized"
            end
          end
        end
      end
    end
  end
end

