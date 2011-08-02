module Fog
  module Terremark
    module Shared
      module Real

        # Get details of an organization
        #
        # ==== Parameters
        # * organization_id<~Integer> - Id of organization to lookup
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'description'<~String> - Description of organization
        #     * 'links'<~Array> - An array of links to entities in the organization
        #       * 'href'<~String> - location of link
        #       * 'name'<~String> - name of link
        #       * 'rel'<~String> - action to perform
        #       * 'type'<~String> - type of link
        #     * 'name'<~String> - Name of organization
        def get_organization(organization_id)
          response = request(
            :expects  => 200,
            :method   => 'GET',
            :parser   => Fog::Parsers::Terremark::Shared::GetOrganization.new,
            :path     => "org/#{organization_id}"
          )
          response
        end

      end

      module Mock

        def get_organization(organization_id)
          organization_id = organization_id.to_i
          response = Excon::Response.new

          if org = @data[:organizations].detect { |org| org[:info][:id] == organization_id }

            body = { "name" => org[:info][:name],
                     "href" => "#{@base_url}/org/#{org[:info][:id]}",
                     "Links" => [] }

            body["Links"] = case self
            when Fog::Terremark::Vcloud::Mock
              _vdc_links(org[:vdcs][0])
            when Fog::Terremark::Ecloud::Mock
              org[:vdcs].map do |vdc|
                _vdc_links(vdc)
              end.flatten
            end

            response.status = 200
            response.body = body
            response.headers = Fog::Terremark::Shared::Mock.headers(response.body, "application/vnd.vmware.vcloud.org+xml")
          else
            response.status = Fog::Terremark::Shared::Mock.unathorized_status
            response.headers = Fog::Terremark::Shared::Mock.error_headers
          end

          response
        end

        private

        def _vdc_links(vdc)
          [{ "name" => vdc[:name],
             "href" => "#{@base_url}/vdc/#{vdc[:id]}",
             "rel" => "down",
             "type" => "application/vnd.vmware.vcloud.vdc+xml" },
           { "name" => "#{vdc[:name]} Catalog",
             "href" => "#{@base_url}/vdc/#{vdc[:id]}/catalog",
             "rel" => "down",
             "type" => "application/vnd.vmware.vcloud.catalog+xml" },
           { "name" => "#{vdc[:name]} Tasks List",
             "href" => "#{@base_url}/vdc/#{vdc[:id]}/taskslist",
             "rel" => "down",
             "type" => "application/vnd.vmware.vcloud.tasksList+xml" }
          ]
        end
      end

    end
  end
end
