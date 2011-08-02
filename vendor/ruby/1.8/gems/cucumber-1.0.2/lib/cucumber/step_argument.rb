module Cucumber
  class StepArgument
    attr_reader :val, :byte_offset

    def initialize(val, byte_offset)
      @val, @byte_offset = val, byte_offset
    end
  end
end