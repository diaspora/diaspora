module RSpec
  module Core
    module SharedContext
      include Hooks

      def included(group)
        [:before, :after].each do |type|
          [:all, :each].each do |scope|
            group.hooks[type][scope].concat hooks[type][scope]
          end
        end
      end

    end
  end
end
