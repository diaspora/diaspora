require 'webmock'

# RSpec 1.x and 2.x compatibility
if defined?(RSpec) && defined?(RSpec::Expectations)
  RSPEC_NAMESPACE = RSPEC_CONFIGURER = RSpec
elsif defined?(Spec)
  RSPEC_NAMESPACE = Spec
  RSPEC_CONFIGURER = Spec::Runner
else  
  begin
    require 'rspec/core'
    require 'rspec/expectations'
    RSPEC_NAMESPACE = RSPEC_CONFIGURER = RSpec
  rescue LoadError
    require 'spec'
    RSPEC_NAMESPACE = Spec
    RSPEC_CONFIGURER = Spec::Runner
  end
end

require 'webmock/rspec/matchers'
  
RSPEC_CONFIGURER.configure { |config|

  config.include WebMock::API
  config.include WebMock::Matchers

  config.after(:each) do
    WebMock.reset!
  end
}

WebMock::AssertionFailure.error_class = RSPEC_NAMESPACE::Expectations::ExpectationNotMetError
