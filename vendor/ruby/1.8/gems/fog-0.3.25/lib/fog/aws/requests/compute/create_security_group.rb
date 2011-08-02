module Fog
  module AWS
    class Compute
      class Real

        # Create a new security group
        #
        # ==== Parameters
        # * group_name<~String> - Name of the security group.
        # * group_description<~String> - Description of group.
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'requestId'<~String> - Id of request
        #     * 'return'<~Boolean> - success?
        def create_security_group(name, description)
          request(
            'Action'            => 'CreateSecurityGroup',
            'GroupName'         => name,
            'GroupDescription'  => CGI.escape(description),
            :parser             => Fog::Parsers::AWS::Compute::Basic.new
          )
        end

      end

      class Mock

        def create_security_group(name, description)
          response = Excon::Response.new
          unless @data[:security_groups][name]
            data = {
              'groupDescription'  => CGI.escape(description).gsub('%20', '+'),
              'groupName'         => CGI.escape(name).gsub('%20', '+'),
              'ipPermissions'     => [],
              'ownerId'           => @owner_id
            }
            @data[:security_groups][name] = data
            response.body = {
              'requestId' => Fog::AWS::Mock.request_id,
              'return'    => true
            }
            response
          else
            raise Fog::AWS::Compute::Error.new("InvalidGroup.Duplicate => The security group '#{name}' already exists")
          end
        end

      end
    end
  end
end
