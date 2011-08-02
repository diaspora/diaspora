require 'active_support/log_subscriber'
require 'active_support/buffered_logger'

module ActiveSupport
  class LogSubscriber
    # Provides some helpers to deal with testing log subscribers by setting up
    # notifications. Take for instance Active Record subscriber tests:
    #
    #   class SyncLogSubscriberTest < ActiveSupport::TestCase
    #     include ActiveSupport::LogSubscriber::TestHelper
    #
    #     def setup
    #       ActiveRecord::LogSubscriber.attach_to(:active_record)
    #     end
    #
    #     def test_basic_query_logging
    #       Developer.all
    #       wait
    #       assert_equal 1, @logger.logged(:debug).size
    #       assert_match /Developer Load/, @logger.logged(:debug).last
    #       assert_match /SELECT \* FROM "developers"/, @logger.logged(:debug).last
    #     end
    #   end
    #
    # All you need to do is to ensure that your log subscriber is added to Rails::Subscriber,
    # as in the second line of the code above. The test helpers is reponsible for setting
    # up the queue, subscriptions and turning colors in logs off.
    #
    # The messages are available in the @logger instance, which is a logger with limited
    # powers (it actually do not send anything to your output), and you can collect them
    # doing @logger.logged(level), where level is the level used in logging, like info,
    # debug, warn and so on.
    #
    module TestHelper
      def setup
        @logger   = MockLogger.new
        @notifier = ActiveSupport::Notifications::Fanout.new

        ActiveSupport::LogSubscriber.colorize_logging = false

        set_logger(@logger)
        ActiveSupport::Notifications.notifier = @notifier
      end

      def teardown
        set_logger(nil)
        ActiveSupport::Notifications.notifier = nil
      end

      class MockLogger
        include ActiveSupport::BufferedLogger::Severity

        attr_reader :flush_count
        attr_accessor :level

        def initialize(level = DEBUG)
          @flush_count = 0
          @level = level
          @logged = Hash.new { |h,k| h[k] = [] }
        end

        def method_missing(level, message)
          @logged[level] << message
        end

        def logged(level)
          @logged[level].compact.map { |l| l.to_s.strip }
        end

        def flush
          @flush_count += 1
        end

        ActiveSupport::BufferedLogger::Severity.constants.each do |severity|
          class_eval <<-EOT, __FILE__, __LINE__ + 1
            def #{severity.downcase}?
              #{severity} >= @level
            end
          EOT
        end
      end

      # Wait notifications to be published.
      def wait
        @notifier.wait
      end

      # Overwrite if you use another logger in your log subscriber:
      #
      #   def logger
      #     ActiveRecord::Base.logger = @logger
      #   end
      #
      def set_logger(logger)
        ActiveSupport::LogSubscriber.logger = logger
      end
    end
  end
end
