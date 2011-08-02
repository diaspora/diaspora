require 'rspec/core'

RSpec.configuration.configure_mock_framework
World(RSpec::Core::MockFrameworkAdapter)

Before do
  RSpec::Mocks::setup(self)
end

After do
  begin
    RSpec::Mocks::verify
  ensure
    RSpec::Mocks::teardown
  end
end