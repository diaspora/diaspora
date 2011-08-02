module Fog
  module Linode
    class Compute
      class Real

        # Issues a shutdown, and then a boot job for a given linode
        #
        # ==== Parameters
        # * linode_id<~Integer>: id of linode to reboot
        # * options<~Hash>:
        #   * configId<~Boolean>: id of config to boot server with
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Array>:
        # TODO: docs
        def linode_reboot(linode_id, options={})
          request(
            :expects  => 200,
            :method   => 'GET',
            :query    => { :api_action => 'linode.reboot', :linodeId => linode_id }.merge!(options)
          )
        end

      end

      class Mock

        def linode_reboot(linode_id, options={})
          Fog::Mock.not_implemented
        end

      end
    end
  end
end
