require 'rails/all'

module RSpecRails
  class Application < ::Rails::Application
  end
end

require 'rspec/rails'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

class RSpec::Core::ExampleGroup
  def self.run_all(reporter=nil)
    run(reporter || RSpec::Mocks::Mock.new('reporter').as_null_object)
  end
end

RSpec.configure do |c|
  c.before(:each) do
    @real_world = RSpec.world
    RSpec.instance_variable_set(:@world, RSpec::Core::World.new)
  end
  c.after(:each) do
    RSpec.instance_variable_set(:@world, @real_world)
  end
end
