module Fog
  module Terremark
    module Shared
      module Real

        # Reserve requested resources and deploy vApp
        #
        # ==== Parameters
        # * vdc_id<~Integer> - Id of vDc to add internet service to
        # * name<~String> - Name of service
        # * protocol<~String> - Protocol of service
        # * port<~Integer> - Port of service
        # * options<~Hash>:
        #   * Enabled<~Boolean>: defaults to true
        #   * Description<~String>: optional description
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'endTime'<~String> - endTime of task
        #     * 'href'<~String> - link to task
        #     * 'startTime'<~String> - startTime of task
        #     * 'status'<~String> - status of task
        #     * 'type'<~String> - type of task
        #     * 'Owner'<~String> -
        #       * 'href'<~String> - href of owner
        #       * 'name'<~String> - name of owner
        #       * 'type'<~String> - type of owner
        def create_internet_service(vdc_id, name, protocol, port, options = {})
          unless options.has_key?('Enabled')
            options['Enabled'] = true
          end
          data = <<-DATA
  <InternetService xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="urn:tmrk:vCloudExpress-1.0:request:createInternetService">
    <Name>#{name}</Name>
    <Protocol>#{protocol.upcase}</Protocol>
    <Port>#{port}</Port>
    <Enabled>#{options['Enabled']}</Enabled>
    <Description>#{options['Description']}</Description>
  </InternetService>
  DATA
          request(
            :body     => data,
            :expects  => 200,
            :headers  => {'Content-Type' => 'application/xml'},
            :method   => 'POST',
            :parser   => Fog::Parsers::Terremark::Shared::InternetService.new,
            :path     => "vdc/#{vdc_id}/internetServices"
          )
        end

      end

      module Mock

        def create_internet_service(vdc_id)
          Fog::Mock.not_implemented
        end

      end
    end
  end
end
