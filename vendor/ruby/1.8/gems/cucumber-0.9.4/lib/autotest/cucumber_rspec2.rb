require 'autotest/cucumber_mixin'
require 'autotest/rspec2'

class Autotest::CucumberRspec2 < Autotest::Rspec2
  include CucumberMixin
end
