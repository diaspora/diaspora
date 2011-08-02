module RSpec::Rails::Matchers
  module RedirectTo
    extend RSpec::Matchers::DSL

    matcher :redirect_to do |destination|
      match_unless_raises ActiveSupport::TestCase::Assertion do |_|
        assert_redirected_to destination
      end

      failure_message_for_should do |_|
        rescued_exception.message
      end

      failure_message_for_should_not do |_|
        "expected not to redirect to #{destination.inspect}, but did"
      end
    end
  end
end
