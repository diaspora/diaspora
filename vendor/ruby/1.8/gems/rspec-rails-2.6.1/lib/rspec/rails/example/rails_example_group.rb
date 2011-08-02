module RSpec
  module Rails
    module RailsExampleGroup
      extend ActiveSupport::Concern
      include RSpec::Rails::SetupAndTeardownAdapter
      include RSpec::Rails::TestUnitAssertionAdapter
    end
  end
end
