require 'active_support/deprecation'

module ActiveSupport
  module Testing
    module Deprecation #:nodoc:
      def assert_deprecated(match = nil, &block)
        result, warnings = collect_deprecations(&block)
        assert !warnings.empty?, "Expected a deprecation warning within the block but received none"
        if match
          match = Regexp.new(Regexp.escape(match)) unless match.is_a?(Regexp)
          assert warnings.any? { |w| w =~ match }, "No deprecation warning matched #{match}: #{warnings.join(', ')}"
        end
        result
      end

      def assert_not_deprecated(&block)
        result, deprecations = collect_deprecations(&block)
        assert deprecations.empty?, "Expected no deprecation warning within the block but received #{deprecations.size}: \n  #{deprecations * "\n  "}"
        result
      end

      private
        def collect_deprecations
          old_behavior = ActiveSupport::Deprecation.behavior
          deprecations = []
          ActiveSupport::Deprecation.behavior = Proc.new do |message, callstack|
            deprecations << message
          end
          result = yield
          [result, deprecations]
        ensure
          ActiveSupport::Deprecation.behavior = old_behavior
        end
    end
  end
end

begin
  require 'test/unit/error'
rescue LoadError
  # Using miniunit, ignore.
else
  module Test
    module Unit
      class Error #:nodoc:
        # Silence warnings when reporting test errors.
        def message_with_silenced_deprecation
          ActiveSupport::Deprecation.silence { message_without_silenced_deprecation }
        end
        alias_method :message_without_silenced_deprecation, :message
        alias_method :message, :message_with_silenced_deprecation
      end
    end
  end
end
