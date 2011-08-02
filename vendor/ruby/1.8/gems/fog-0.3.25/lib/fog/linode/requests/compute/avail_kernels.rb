module Fog
  module Linode
    class Compute
      class Real

        # Get available kernels
        #
        # ==== Parameters
        # * options<~Hash>:
        #   * kernelId<~Integer>: id to limit results to
        #   * isXen<~Integer>: if 1 limits results to only zen
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Array>:
        # TODO: docs
        def avail_kernels(options={})
          request(
            :expects  => 200,
            :method   => 'GET',
            :query    => { :api_action => 'avail.kernels' }.merge!(options)
          )
        end

      end

      class Mock

        def avail_kernels(options={})
          Fog::Mock.not_implemented
        end

      end
    end
  end
end
