module FactoryGirl
  class Proxy #:nodoc:
    class Build < Proxy #:nodoc:
      def initialize(klass)
        @instance = klass.new
      end

      def get(attribute)
        @instance.send(attribute)
      end

      def set(attribute, value)
        @instance.send(:"#{attribute}=", value)
      end

      def associate(name, factory_name, overrides)
        factory = FactoryGirl.factory_by_name(factory_name)
        set(name, factory.run(Proxy::Create, overrides))
      end

      def association(factory_name, overrides = {})
        factory = FactoryGirl.factory_by_name(factory_name)
        factory.run(Proxy::Create, overrides)
      end

      def result(to_create)
        run_callbacks(:after_build)
        @instance
      end
    end
  end
end
