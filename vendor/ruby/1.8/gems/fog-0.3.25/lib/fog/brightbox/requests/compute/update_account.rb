module Fog
  module Brightbox
    class Compute
      class Real

        def update_account(options = {})
          return nil if options.empty? || options.nil?
          request(
            :expects  => [200],
            :method   => 'PUT',
            :path     => "/1.0/account",
            :headers  => {"Content-Type" => "application/json"},
            :body     => options.to_json
          )
        end

      end

      class Mock

        def update_account(options = {})
          Fog::Mock.not_implemented
        end

      end
    end
  end
end