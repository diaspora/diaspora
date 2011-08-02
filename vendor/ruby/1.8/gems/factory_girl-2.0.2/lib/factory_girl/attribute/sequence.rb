module FactoryGirl
  class Attribute

    class Sequence < Attribute
      def initialize(name, sequence)
        super(name)
        @sequence = sequence
      end

      def add_to(proxy)
        proxy.set(name, FactoryGirl.generate(@sequence))
      end
    end

  end
end
