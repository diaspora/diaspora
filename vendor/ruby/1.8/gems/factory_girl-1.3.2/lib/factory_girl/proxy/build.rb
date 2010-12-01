class Factory
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

      def associate(name, factory, attributes)
        set(name, Factory.create(factory, attributes))
      end

      def association(factory, overrides = {})
        Factory.create(factory, overrides)
      end

      def result
        run_callbacks(:after_build)
        @instance
      end
    end
  end
end
