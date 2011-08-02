module Typhoeus
  class Hydra
    class NetConnectNotAllowedError < StandardError; end

    module ConnectOptions
      def self.included(base)
        base.extend(ClassMethods)
      end

      # This method checks to see if we should raise an error on
      # a request.
      #
      # @raises NetConnectNotAllowedError
      def check_allow_net_connect!(request)
        return if Typhoeus::Hydra.allow_net_connect?
        return if Typhoeus::Hydra.ignore_hosts.include?(request.host_domain)

        raise NetConnectNotAllowedError, "Real HTTP requests are not allowed. Unregistered request: #{request.inspect}"
      end
      private :check_allow_net_connect!

      module ClassMethods
        def self.extended(base)
          class << base
            attr_accessor :allow_net_connect
            attr_accessor :ignore_localhost
          end
          base.allow_net_connect = true
          base.ignore_localhost = false
        end

        # Returns whether we allow external HTTP connections.
        # Useful for mocking/tests.
        #
        # @return [boolean] true/false
        def allow_net_connect?
          allow_net_connect
        end

        def ignore_localhost?
          ignore_localhost
        end

        def ignore_hosts
          @ignore_hosts ||= []

          if ignore_localhost?
            @ignore_hosts + Typhoeus::Request::LOCALHOST_ALIASES
          else
            @ignore_hosts
          end
        end

        def ignore_hosts=(hosts)
          @ignore_hosts = hosts
        end
      end
    end
  end
end

