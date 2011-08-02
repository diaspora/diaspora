module RSpec::Rails::Matchers
  module RenderTemplate
    extend RSpec::Matchers::DSL

    matcher :render_template do |options, message|
      match_unless_raises ActiveSupport::TestCase::Assertion do |_|
        options = options.to_s if Symbol === options
        assert_template options, message
      end

      failure_message_for_should do
        rescued_exception.message
      end

      failure_message_for_should_not do |_|
        "expected not to render #{options.inspect}, but did"
      end
    end
  end
end
