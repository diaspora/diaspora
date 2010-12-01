require 'autotest'
require 'autotest/cucumber_mixin'

class Autotest::Cucumber < Autotest
  include CucumberMixin
end
