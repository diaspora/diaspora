module Fog
  module Brightbox
    class Compute
      class Real

        def unmap_cloud_ip(identifier, options = {})
          return nil if identifier.nil? || identifier == ""
          request(
            :expects  => [202],
            :method   => 'POST',
            :path     => "/1.0/cloud_ips/#{identifier}/unmap",
            :headers  => {"Content-Type" => "application/json"},
            :body     => options.to_json
          )
        end

      end

      class Mock

        def unmap_cloud_ip(identifier, options = {})
          Fog::Mock.not_implemented
        end

      end
    end
  end
end