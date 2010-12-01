class Factory
  class Attribute #:nodoc:

    class Static < Attribute  #:nodoc:

      def initialize(name, value)
        super(name)
        @value = value
      end

      def add_to(proxy)
        proxy.set(name, @value)
      end
    end

  end
end
