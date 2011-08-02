require 'gherkin/native'
require 'gherkin/formatter/hashable'

module Gherkin
  module Formatter
    class Argument < Hashable
      native_impl('gherkin')
      attr_reader :offset, :val

      # Creates a new Argument that starts at character offset +offset+ with value +val+
      def initialize(offset, val)
        @offset, @val = offset, val
      end
    end
  end
end
