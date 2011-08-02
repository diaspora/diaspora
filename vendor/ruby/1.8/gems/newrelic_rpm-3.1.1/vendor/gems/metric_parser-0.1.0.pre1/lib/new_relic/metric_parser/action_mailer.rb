require 'new_relic/metric_parser'
module NewRelic
  module MetricParser
    class ActionMailer < NewRelic::MetricParser::MetricParser

      def is_action_mailer?; true; end

      def short_name
        "ActionMailer - #{segments[1]}"
      end

    end
  end
end
