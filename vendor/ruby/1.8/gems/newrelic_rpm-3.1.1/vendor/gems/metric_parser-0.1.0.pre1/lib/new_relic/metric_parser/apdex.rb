require 'new_relic/metric_parser'
module NewRelic
  module MetricParser
    class Apdex < NewRelic::MetricParser::MetricParser

      CLIENT = 'Client'

      # Convenience method for creating the appropriate client
      # metric name.
      def self.client_metric(apdex_t)
        "Apdex/#{CLIENT}/#{apdex_t}"
      end
      def self.browser_client_metric(os, browser, version, apdex_t)
        "#{self.client_metric(apdex_t)}/#{os}/#{browser}/#{version}"
      end

      def is_apdex?; true; end
      def is_client?
        segments[1] == CLIENT
      end
      def is_client_summary?
        is_client? && segments.size == 3
      end
      def is_browser_summary?
        is_client? && segments.size == 6
      end
      def is_summary?
        segments.size == 1
      end

      # Apdex/Client/N
      def apdex_t
        is_client? && segments[2].to_f
      end

      def platform
        is_browser_summary? && segments[3]
      end

      def browser
        is_browser_summary? && segments[4]
      end

      def browser_version
        is_browser_summary? && segments[5]
      end

      def user_agent
        is_browser_summary? && segments[4..-1].join(" ")
      end

      def platform_and_user_agent
        is_browser_summary? && segments[3..-1].join(" ")
      end

      def developer_name
        case
        when is_client? then "Apdex Client (#{apdex_t})"
        when is_browser_summary? then "Apdex Client for #{os_and_browser} (#{apdex_t})"
        when is_summary? then "Apdex"
        else "Apdex #{segments[1..-1].join("/")}"
        end
      end

      def short_name
        # standard controller actions
        if segments.length > 1
          url
        else
          'All Frontend Urls'
        end
      end

      def url
        '/' + segments[1..-1].join('/')
      end

      # this is used to match transaction traces to controller actions.
      # TT's don't have a preceding slash :P
      def tt_path
        segments[1..-1].join('/')
      end

      def call_rate_suffix
        'rpm'
      end
    end
  end
end
