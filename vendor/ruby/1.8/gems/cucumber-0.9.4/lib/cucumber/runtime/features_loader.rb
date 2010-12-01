require 'cucumber/errors'

module Cucumber
  class Runtime
    
    class FeaturesLoader
      include Formatter::Duration

      def initialize(feature_files, filters, tag_expression)
        @feature_files, @filters, @tag_expression = feature_files, filters, tag_expression
      end
      
      def features
        load unless @features
        @features
      end
      
    private
    
      def load
        features = Ast::Features.new

        tag_counts = {}
        start = Time.new
        log.debug("Features:\n")
        @feature_files.each do |f|
          feature_file = FeatureFile.new(f)
          feature = feature_file.parse(@filters, tag_counts)
          if feature
            features.add_feature(feature)
            log.debug("  * #{f}\n")
          end
        end
        duration = Time.now - start
        log.debug("Parsing feature files took #{format_duration(duration)}\n\n")

        check_tag_limits(tag_counts)

        @features = features
      end

      def check_tag_limits(tag_counts)
        error_messages = []
        @tag_expression.limits.each do |tag_name, tag_limit|
          tag_locations = (tag_counts[tag_name] || [])
          tag_count = tag_locations.length
          if tag_count > tag_limit
            error = "#{tag_name} occurred #{tag_count} times, but the limit was set to #{tag_limit}\n  " +
              tag_locations.join("\n  ")
            error_messages << error
          end
        end
        raise TagExcess.new(error_messages) if error_messages.any?
      end
      
      def log
        Cucumber.logger
      end
    end

  end
end
