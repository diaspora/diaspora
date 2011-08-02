module FactoryGirl
  class Attribute

    class Implicit < Attribute
      def initialize(name)
        super(name)
      end

      def add_to(proxy)
        implementation.add_to(proxy)
      end

      def association?
        implementation.association?
      end

      def factory
        name
      end

      private

      def implementation
        @implementation ||= resolve_name
      end

      def resolve_name
        if FactoryGirl.factories.registered?(name)
          Attribute::Association.new(name, name, {})
        else
          Attribute::Sequence.new(name, name)
        end
      end
    end
  end
end
