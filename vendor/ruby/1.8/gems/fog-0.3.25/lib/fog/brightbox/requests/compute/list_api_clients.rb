module Fog
  module Brightbox
    class Compute
      class Real

        def list_api_clients(options = {})
          request(
            :expects  => [200],
            :method   => 'GET',
            :path     => "/1.0/api_clients",
            :headers  => {"Content-Type" => "application/json"},
            :body     => options.to_json
          )
        end

      end

      class Mock

        def list_api_clients(options = {})
          Fog::Mock.not_implemented
        end

      end
    end
  end
end