module Fog
  module Linode
    class Compute
      class Real

        # Get available stack scripts
        #
        # ==== Parameters
        # * options<~Hash>:
        #   * distributionId<~Integer>: Limit the results to Stackscripts that can be applied to this distribution id
        #   * distributionVendor<~String>: Debian, Ubuntu, Fedora, etc.
        #   * keywords<~String>: Search terms
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Array>:
        # TODO: docs
        def avail_stackscripts(options={})
          request(
            :expects  => 200,
            :method   => 'GET',
            :query    => { :api_action => 'avail.stackscripts' }.merge!(options)
          )
        end

      end

      class Mock

        def avail_stackscripts(options={})
          Fog::Mock.not_implemented
        end

      end
    end
  end
end
