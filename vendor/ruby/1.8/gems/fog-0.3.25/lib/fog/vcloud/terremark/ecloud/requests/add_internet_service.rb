module Fog
  class Vcloud
    module Terremark
      class Ecloud
        module Shared
          def validate_internet_service_monitor(monitor)
            #FIXME: Refactor this type of function into something generic
            required_opts = [:type, :url_send_string, :http_headers, :receive_string, :is_enabled]

            unless required_opts.all? { |opt| monitor.keys.include?(opt) && monitor[opt] }
              raise ArgumentError.new("Required Monitor data missing: #{(required_opts - monitor.keys).map(&:inspect).join(", ")}")
            end

            unless ['HTTP','ECV'].include?(monitor[:type])
              raise ArgumentError.new("Supported monitor types are: ECV & HTTP")
            end

            unless monitor[:http_headers].is_a?(Array) || monitor[:http_headers].is_a?(String)
              raise ArgumentError.new("Monitor :http_headers must be a String or Array")
            end

            unless [true, false, "true", "false"].include?(monitor[:is_enabled])
              raise ArgumentError.new("Monitor :is_enabled must be true or false")
            end
          end

          def validate_internet_service_data(service_data, configure=false)
            required_opts = [:name, :protocol, :port, :description, :enabled]
            if configure
              required_opts + [ :id, :href, :timeout ]
            end
            unless required_opts.all? { |opt| service_data.keys.include?(opt) }
              raise ArgumentError.new("Required Internet Service data missing: #{(required_opts - service_data.keys).map(&:inspect).join(", ")}")
            end
          end
        end

        class Real
          include Shared

          def add_internet_service(internet_services_uri, service_data)
            validate_internet_service_data(service_data)
            if monitor = service_data[:monitor]
              validate_internet_service_monitor(monitor)
              ensure_monitor_defaults!(monitor)
            end

            request(
              :body     => generate_internet_service_request(service_data),
              :expects  => 200,
              :headers  => {'Content-Type' => 'application/vnd.tmrk.ecloud.internetService+xml'},
              :method   => 'POST',
              :uri      => internet_services_uri,
              :parse    => true
            )
          end

          private

          def generate_internet_service_request(service_data)
            builder = Builder::XmlMarkup.new
            builder.CreateInternetServiceRequest(:"xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
                                                 :"xmlns:xsd" => "http://www.w3.org/2001/XMLSchema",
                                                 :xmlns => "urn:tmrk:eCloudExtensions-2.3") {
              builder.Name(service_data[:name])
              builder.Protocol(service_data[:protocol])
              builder.Port(service_data[:port])
              builder.Enabled(service_data[:enabled])
              builder.Description(service_data[:description])
              builder.RedirectURL(service_data[:redirect_url])
              if monitor = service_data[:monitor]
                generate_monitor_section(builder,monitor)
              end
            }
          end

          def generate_monitor_section(builder, monitor)
            builder.Monitor {
              builder.MonitorType(monitor[:type])
              builder.UrlSendString(monitor[:url_send_string])
              builder.HttpHeader(monitor[:http_headers].join("\n"))
              builder.ReceiveString(monitor[:receive_string])
              builder.Interval(monitor[:interval])
              builder.ResponseTimeOut(monitor[:response_timeout])
              builder.DownTime(monitor[:downtime])
              builder.Retries(monitor[:retries])
              builder.IsEnabled(monitor[:is_enabled])
            }
          end

          def ensure_monitor_defaults!(monitor)
            if monitor[:http_headers].is_a?(String)
              monitor[:http_headers] = [ monitor[:http_headers] ]
            end

            unless monitor[:retries]
              monitor[:retries] = 3
            end

            unless monitor[:response_timeout]
              monitor[:response_timeout] = 2
            end

            unless monitor[:down_time]
              monitor[:down_time] = 30
            end

            unless monitor[:interval]
              monitor[:interval] = 5
            end
          end
        end

        class Mock
          include Shared

          #
          # Based on
          # http://support.theenterprisecloud.com/kb/default.asp?id=561&Lang=1&SID=
          #

          def add_internet_service(internet_services_uri, service_data)
            validate_internet_service_data(service_data)

            internet_services_uri = ensure_unparsed(internet_services_uri)

            if public_ip_internet_service_collection = mock_data.public_ip_internet_service_collection_from_href(internet_services_uri)
              new_public_ip_internet_service = MockPublicIpInternetService.new(service_data, public_ip_internet_service_collection)
              public_ip_internet_service_collection.items << new_public_ip_internet_service
              xml = generate_internet_service_response(new_public_ip_internet_service)

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

