module Fog
  module Terremark
    module Shared
      module Real

        # Get list of organizations
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Array>:
        #     * 'description'<~String> - Description of organization
        #     * 'links'<~Array> - An array of links to entities in the organization
        #     * 'name'<~String> - Name of organization
        def get_organizations
          request({
            :expects  => 200,
            :headers  => {
              'Authorization' => "Basic #{Base64.encode64("#{@terremark_username}:#{@terremark_password}").chomp!}",
              # Terremark said they're going to remove passing in the Content-Type to login in a future release
              'Content-Type'  => "application/vnd.vmware.vcloud.orgList+xml"
            },
            :method   => 'POST',
            :parser   => Fog::Parsers::Terremark::Shared::GetOrganizations.new,
            :path     => 'login'
          })
        end

      end

      module Mock

        def get_organizations
          response = Excon::Response.new
          org_list = @data[:organizations].map do |organization|
            { "name" => organization[:info][:name],
              "href" => "#{@base_url}/org/#{organization[:info][:id]}",
              "type" => "application/vnd.vmware.vcloud.org+xml"
            }
          end
          response.body = { "OrgList" => org_list }
          response.status = 200
          response.headers = Fog::Terremark::Shared::Mock.headers(response.body, "application/vnd.vmware.vcloud.orgList+xml")
          response
        end

      end
    end
  end
end
