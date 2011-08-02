require 'autotest/cucumber_mixin'
require 'autotest/rails_rspec2'

class Autotest::CucumberRailsRspec2 < Autotest::RailsRspec2
  include CucumberMixin
end
