require 'rails/all'

module RSpecRails
  class Application < ::Rails::Application
  end
end

require 'rspec/rails'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

# TODO - most of this is borrowed from rspec-core's spec_helper - should
# be extracted to something we can use here
def in_editor?
  ENV.has_key?('TM_MODE') || ENV.has_key?('EMACS') || ENV.has_key?('VIM')
end

class RSpec::Core::ExampleGroup
  def self.run_all(reporter=nil)
    run(reporter || RSpec::Mocks::Mock.new('reporter').as_null_object)
  end
end

module MatchesForRSpecRailsSpecs
  extend RSpec::Matchers::DSL

  matcher :be_included_in_files_in do |path|
    match do |mod|
      stub_metadata(
        :example_group => {:file_path => "#{path}whatever_spec.rb:15"}
      )
      group = RSpec::Core::ExampleGroup.describe
      group.included_modules.include?(mod)
    end
  end
end

RSpec.configure do |c|
  c.include MatchesForRSpecRailsSpecs
  c.color_enabled = !in_editor?
  c.before(:each) do
    @real_world = RSpec.world
    RSpec.instance_variable_set(:@world, RSpec::Core::World.new)
  end
  c.after(:each) do
    RSpec.instance_variable_set(:@world, @real_world)
  end
end
