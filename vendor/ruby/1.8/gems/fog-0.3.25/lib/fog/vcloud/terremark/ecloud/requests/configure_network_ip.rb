module Fog
  class Vcloud
    module Terremark
      class Ecloud
        class Real

          def validate_network_ip_data(network_ip_data, configure=false)
            valid_opts = [:id, :href, :name, :status, :server, :rnat]
            unless valid_opts.all? { |opt| network_ip_data.keys.include?(opt) }
              raise ArgumentError.new("Required data missing: #{(valid_opts - network_ip_data.keys).map(&:inspect).join(", ")}")
            end
          end

          def configure_network_ip(network_ip_uri, network_ip_data)
            validate_network_ip_data(network_ip_data)

            request(
              :body     => generate_configure_network_ip_request(network_ip_data),
              :expects  => 200,
              :headers  => {'Content-Type' => 'application/vnd.tmrk.ecloud.ip+xml' },
              :method   => 'PUT',
              :uri      => network_ip_uri,
              :parse    => true
            )
          end

          private

          def generate_configure_network_ip_request(network_ip_data)
            builder = Builder::XmlMarkup.new
            builder.IpAddress(:"xmlns:i" => "http://www.w3.org/2001/XMLSchema-instance",
                              :xmlns => "urn:tmrk:eCloudExtensions-2.3") {
              builder.Id(network_ip_data[:id])
              builder.Href(network_ip_data[:href])
              builder.Name(network_ip_data[:name])
              builder.Status(network_ip_data[:status])
              builder.Server(network_ip_data[:server])
              builder.RnatAddress(network_ip_data[:rnat])
            }
          end

        end

        class Mock

          def configure_network_ip(network_ip_uri, network_ip_data)
            Fog::Mock.not_implemented
          end
        end
      end
    end
  end
end
