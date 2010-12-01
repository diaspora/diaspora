module RSpec::Rails::Matchers
  module RenderTemplate
    extend RSpec::Matchers::DSL

    matcher :render_template do |options, message|
      match_unless_raises Test::Unit::AssertionFailedError do |_|
        options = options.to_s if Symbol === options
        assert_template options, message
      end

      failure_message_for_should do
        rescued_exception.message
      end
    end
  end
end
