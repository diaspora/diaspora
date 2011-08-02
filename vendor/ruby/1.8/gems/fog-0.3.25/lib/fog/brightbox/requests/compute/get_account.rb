module Fog
  module Brightbox
    class Compute
      class Real

        def get_account(options = {})
          request(
            :expects  => [200],
            :method   => 'GET',
            :path     => "/1.0/account",
            :headers  => {"Content-Type" => "application/json"},
            :body     => options.to_json
          )
        end

      end

      class Mock

        def get_account(options = {})
          Fog::Mock.not_implemented
        end

      end
    end
  end
end