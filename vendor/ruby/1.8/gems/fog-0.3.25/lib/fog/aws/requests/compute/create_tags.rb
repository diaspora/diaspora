module Fog
  module AWS
    class Compute
      class Real

        # Adds tags to resources
        #
        # ==== Parameters
        # * resources<~String> - One or more resources to tag
        # * tags<~String> - hash of key value tag pairs to assign
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'requestId'<~String> - Id of request
        #     * 'return'<~Boolean> - success?
        def create_tags(resources, tags)
          resources = [*resources]
          for key, value in tags
            if value.nil?
              tags[key] = ''
            end
          end
          params = {}
          params.merge!(AWS.indexed_param('ResourceId', resources))
          params.merge!(AWS.indexed_param('Tag.%d.Key', tags.keys))
          params.merge!(AWS.indexed_param('Tag.%d.Value', tags.values))
          request({
            'Action'            => 'CreateTags',
            :parser             => Fog::Parsers::AWS::Compute::Basic.new
          }.merge!(params))
        end

      end

      class Mock

        def create_tags(resources, tags)
          resources = [*resources]

          tagged = resources.map do |resource_id|
            type = case resource_id
            when /^ami\-[a-z0-9]{8}$/i
              'image'
            when /^i\-[a-z0-9]{8}$/i
              'instance'
            when /^snap\-[a-z0-9]{8}$/i
              'snapshot'
            when /^vol\-[a-z0-9]{8}$/i
              'volume'
            end
            if type && @data[:"#{type}s"][resource_id]
              { 'resourceId' => resource_id, 'resourceType' => type }
            else
              raise(Fog::Service::NotFound.new("The #{type} ID '#{resource_id}' does not exist"))
            end
          end

          tags.each do |key, value|
            @data[:tags][key] ||= {}
            @data[:tags][key][value] ||= []
            @data[:tags][key][value] = @data[:tags][key][value] & tagged
          end

          response = Excon::Response.new
          response.status = 200
          response.body = {
            'requestId' => Fog::AWS::Mock.request_id,
            'return'    => true
          }
          response
        end

      end

    end
  end
end
