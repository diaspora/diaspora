module Fog
  module Linode
    class Compute
      class Real

        # Creates a linode and assigns you full privileges
        #
        # ==== Parameters
        # * datacenter_id<~Integer>: id of datacenter to place new linode in
        # * payment_term<~Integer>: Subscription term in months, in [1, 12, 24]
        # * plan_id<~Integer>: id of plan to boot new linode with
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Array>:
        # TODO: docs
        def linode_create(datacenter_id, payment_term, plan_id)
          request(
            :expects  => 200,
            :method   => 'GET',
            :query    => {
              :api_action   => 'linode.create',
              :datacenterId => datacenter_id,
              :paymentTerm  => payment_term,
              :planId       => plan_id
            }
          )
        end

      end

      class Mock

        def linode_create(datacenter_id, payment_term, plan_id)
          Fog::Mock.not_implemented
        end

      end
    end
  end
end
