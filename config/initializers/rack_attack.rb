# frozen_string_literal: true

module Rack
  class Attack
    class Request
      def throttleable_ip
        parsed = IPAddr.new(ip)

        if parsed.ipv6? && !parsed.ipv4_mapped?
          # Throttle all requests from the same /64 IPv6 subnet
          parsed.mask(64)
        else
          parsed
        end.to_s
      end
    end

    throttle("logins/ip", limit: 20, period: 5.minutes) do |req|
      req.throttleable_ip if req.post? && req.path.start_with?("/users/sign_in")
    end

    throttle("otp/user_id", limit: 20, period: 1.hour) do |req|
      req.session[:otp_user_id] if req.post? && req.path.start_with?("/users/sign_in") && req.session[:otp_user_id]
    end
  end
end
