require 'cucumber/runtime'

module Cucumber
  class StepMother < Runtime
    def initialize(*args)
      warn("StepMother has been deprecated and will be gently put to sleep at the next major release. Please use Runtime instead. #{caller[0]}")
      super
    end
  end
end