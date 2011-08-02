module Fog
  class Vcloud
    module Terremark
      class Ecloud

        class Real

          def validate_clone_vapp_options(options)
            valid_opts = [:name, :poweron]
            unless valid_opts.all? { |opt| options.keys.include?(opt) }
              raise ArgumentError.new("Required data missing: #{(valid_opts - options.keys).map(&:inspect).join(", ")}")
            end
          end

          def generate_clone_vapp_request(uri, options)
            xml = Builder::XmlMarkup.new
            xml.CloneVAppParams(xmlns.merge!(:name => options[:name], :deploy => "true", :powerOn => options[:poweron])) {
              xml.VApp( :href => uri, :type => "application/vnd.vmware.vcloud.vApp+xml",
                        :xmlns => "http://www.vmware.com/vcloud/v0.8")
            }
          end

          def clone_vapp(vdc_uri, vapp_uri, options = {})
            unless options.has_key?(:poweron)
              options[:poweron] = "false"
            end

            validate_clone_vapp_options(options)

            request(
              :body     => generate_clone_vapp_request(vapp_uri, options),
              :expects  => 202,
              :headers  => {'Content-Type' => 'application/vnd.vmware.vcloud.cloneVAppParams+xml'},
              :method   => 'POST',
              :uri      => vdc_uri + '/action/clonevapp',
              :parse    => true
            )
          end
        end

        class Mock
          def clone_vapp(vdc_uri, vapp_uri, customization_data)
            validate_customization_data(customization_data)
            Fog::Mock.not_implemented
          end
        end
      end
    end
  end
end
