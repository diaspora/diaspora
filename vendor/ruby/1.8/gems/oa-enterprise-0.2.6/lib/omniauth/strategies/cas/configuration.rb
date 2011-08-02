require 'rack'

module OmniAuth
  module Strategies
    class CAS
      class Configuration

        DEFAULT_LOGIN_URL = "%s/login"

        DEFAULT_SERVICE_VALIDATE_URL = "%s/serviceValidate"

        # @param [Hash] params configuration options
        # @option params [String, nil] :cas_server the CAS server root URL; probably something like
        #         `http://cas.mycompany.com` or `http://cas.mycompany.com/cas`; optional.
        # @option params [String, nil] :cas_login_url (:cas_server + '/login') the URL to which to
        #         redirect for logins; options if `:cas_server` is specified,
        #         required otherwise.
        # @option params [String, nil] :cas_service_validate_url (:cas_server + '/serviceValidate') the
        #         URL to use for validating service tickets; optional if `:cas_server` is
        #         specified, requred otherwise.
        # @option params [Boolean, nil] :disable_ssl_verification disable verification for SSL cert,
        #         helpful when you developing with a fake cert.
        def initialize(params)
          parse_params params
        end

        # Build a CAS login URL from +service+.
        #
        # @param [String] service the service (a.k.a. return-to) URL
        #
        # @return [String] a URL like `http://cas.mycompany.com/login?service=...`
        def login_url(service)
          append_service @login_url, service
        end

        # Build a service-validation URL from +service+ and +ticket+.
        # If +service+ has a ticket param, first remove it. URL-encode
        # +service+ and add it and the +ticket+ as paraemters to the
        # CAS serviceValidate URL.
        #
        # @param [String] service the service (a.k.a. return-to) URL
        # @param [String] ticket the ticket to validate
        #
        # @return [String] a URL like `http://cas.mycompany.com/serviceValidate?service=...&ticket=...`
        def service_validate_url(service, ticket)
          service = service.sub(/[?&]ticket=[^?&]+/, '')
          url = append_service(@service_validate_url, service)
          url << '&ticket=' << Rack::Utils.escape(ticket)
        end

        def disable_ssl_verification?
          @disable_ssl_verification
        end

        private

        def parse_params(params)
          if params[:cas_server].nil? && params[:cas_login_url].nil?
            raise ArgumentError.new(":cas_server or :cas_login_url MUST be provided")
          end
          @login_url   = params[:cas_login_url]
          @login_url ||= DEFAULT_LOGIN_URL % params[:cas_server]
          validate_is_url 'login URL', @login_url

          if params[:cas_server].nil? && params[:cas_service_validate_url].nil?
            raise ArgumentError.new(":cas_server or :cas_service_validate_url MUST be provided")
          end
          @service_validate_url   = params[:cas_service_validate_url]
          @service_validate_url ||= DEFAULT_SERVICE_VALIDATE_URL % params[:cas_server]
          validate_is_url 'service-validate URL', @service_validate_url

          @disable_ssl_verification = params[:disable_ssl_verification]
        end

        IS_NOT_URL_ERROR_MESSAGE = "%s is not a valid URL"

        def validate_is_url(name, possibly_a_url)
          url = URI.parse(possibly_a_url) rescue nil
          raise ArgumentError.new(IS_NOT_URL_ERROR_MESSAGE % name) unless url.kind_of?(URI::HTTP)
        end

        # Adds +service+ as an URL-escaped parameter to +base+.
        #
        # @param [String] base the base URL
        # @param [String] service the service (a.k.a. return-to) URL.
        #
        # @return [String] the new joined URL.
        def append_service(base, service)
          result = base.dup
          result << (result.include?('?') ? '&' : '?')
          result << 'service='
          result << Rack::Utils.escape(service)
        end

      end
    end
  end
end
