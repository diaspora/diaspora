module Fog
  module Brightbox
    class Compute
      class Real

        def reset_ftp_password_account(options = {})
          request(
            :expects  => [200],
            :method   => 'POST',
            :path     => "/1.0/account/reset_ftp_password",
            :headers  => {"Content-Type" => "application/json"},
            :body     => options.to_json
          )
        end

      end

      class Mock

        def reset_ftp_password_account(options = {})
          Fog::Mock.not_implemented
        end

      end
    end
  end
end