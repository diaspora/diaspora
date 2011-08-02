module Fog
  module Linode
    class Compute
      class Real

        # Get available plans
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Array>:
        # TODO: docs
        def avail_linodeplans(linodeplan_id = nil)
          options = {}
          if linodeplan_id
            options.merge!(:planId => linodeplan_id)
          end
          request(
            :expects  => 200,
            :method   => 'GET',
            :query    => { :api_action => 'avail.linodeplans' }.merge!(options)
          )
        end

      end

      class Mock

        def avail_linodeplans(linodeplan_id = nil)
          Fog::Mock.not_implemented
        end

      end
    end
  end
end
