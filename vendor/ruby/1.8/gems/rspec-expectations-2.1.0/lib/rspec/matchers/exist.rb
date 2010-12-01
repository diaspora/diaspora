module RSpec
  module Matchers
    # :call-seq:
    #   should exist
    #   should_not exist
    #
    # Passes if actual.exist?
    def exist(arg=nil)
      Matcher.new :exist do
        match do |actual|
          arg ? actual.exist?(arg) : actual.exist?
        end
      end
    end
  end
end
