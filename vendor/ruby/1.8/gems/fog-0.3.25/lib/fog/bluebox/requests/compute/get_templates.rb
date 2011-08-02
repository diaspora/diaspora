module Fog
  module Bluebox
    class Compute
      class Real

        # Get list of OS templates
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Array>:
        #     * 'id'<~String> - UUID of the image
        #     * 'description'<~String> - Description of the image
        #     * 'public'<~Boolean> - Public / Private image
        #     * 'created'<~Datetime> - Timestamp of when the image was created
        def get_templates
          request(
            :expects  => 200,
            :method   => 'GET',
            :path     => 'api/block_templates.json'
          )
        end

      end

      class Mock

        def get_templates
          Fog::Mock.not_implemented
        end

      end
    end
  end
end
