# TODO: Not even sure is this is necessary anymore, since we're doing this in Cucumber's rb_world.rb...
require 'cucumber/rails/world'

begin
  require 'rspec/rails/matchers'

  [Cucumber::Rails::World, ActionController::Integration::Session].each do |klass|
    klass.class_eval do
      include RSpec::Matchers
    end
  end
rescue LoadError => try_rspec_1
  require 'spec/expectations'
  require 'spec/rails'

  [Cucumber::Rails::World, ActionController::Integration::Session].each do |klass|
    klass.class_eval do
      include Spec::Matchers
      include Spec::Rails::Matchers if defined?(Spec::Rails::Matchers)
    end
  end
end
