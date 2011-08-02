module Fog
  module Bluebox
    class Compute
      class Real

        # Get details of a template
        #
        # ==== Parameters
        # * template_id<~Integer> - Id of template to lookup
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Array>:
        # TODO
        def get_template(template_id)
          request(
            :expects  => 200,
            :method   => 'GET',
            :path     => "api/block_templates/#{template_id}.json"
          )
        end

      end

      class Mock

        def get_template(template_id)
          Fog::Mock.not_implemented
        end

      end
    end
  end
end
