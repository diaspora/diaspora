module Fog
  module Terremark
    module Shared
      module Real

        # Reserve requested resources and deploy vApp
        #
        # ==== Parameters
        # * service_id<~String> - Id of service to add node to
        # * ip<~String> - Private ip of server to add to node
        # * name<~String> - Name of service
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
        def add_node_service(service_id, ip, name, port, options = {})
          unless options.has_key?('Enabled')
            options['Enabled'] = true
          end
          data = <<-DATA
  <NodeService xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="urn:tmrk:vCloudExpress-1.0:request:createNodeService">
    <IpAddress>#{ip}</IpAddress>
    <Name>#{name}</Name>
    <Port>#{port}</Port>
    <Enabled>#{options['Enabled']}</Enabled>
    <Description>#{options['Description']}</Description>
  </NodeService>
  DATA
          request(
            :body     => data,
            :expects  => 200,
            :headers  => {'Content-Type' => 'application/xml'},
            :method   => 'POST',
            :parser   => Fog::Parsers::Terremark::Shared::InternetService.new,
            :path     => "internetServices/#{service_id}/nodes"
          )
        end

      end

      module Mock

        def add_node_service(ip)
          Fog::Mock.not_implemented
        end

      end
    end
  end
end
