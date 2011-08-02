module Fog
  module Linode
    class Compute
      class Real

        # Get available distributions
        #
        # ==== Parameters
        # * distributionId<~Integer>: id to limit results to
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Array>:
        # TODO: docs
        def avail_distributions(distribution_id=nil)
          options = {}
          if distribution_id
            options.merge!(:distributionId => distribution_id)
          end
          request(
            :expects  => 200,
            :method   => 'GET',
            :query    => { :api_action => 'avail.distributions' }.merge!(options)
          )
        end

      end

      class Mock

        def avail_distributions(options={})
          Fog::Mock.not_implemented
        end

      end
    end
  end
end
