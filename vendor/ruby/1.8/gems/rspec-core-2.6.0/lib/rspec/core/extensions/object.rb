module RSpec
  module Core
    module ObjectExtensions
      def describe(*args, &example_group_block)
        RSpec::Core::ExampleGroup.describe(*args, &example_group_block).register
      end
    end
  end
end

class Object
  include RSpec::Core::ObjectExtensions
end
