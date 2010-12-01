module RSpec::Rails::Matchers
  module RedirectTo
    extend RSpec::Matchers::DSL

    matcher :redirect_to do |destination|
      match_unless_raises Test::Unit::AssertionFailedError do |_|
        assert_redirected_to destination
      end

      failure_message_for_should do
        rescued_exception.message
      end
    end
  end
end
