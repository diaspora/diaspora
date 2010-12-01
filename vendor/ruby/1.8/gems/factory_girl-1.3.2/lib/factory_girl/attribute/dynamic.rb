class Factory
  class Attribute #:nodoc:

    class Dynamic < Attribute  #:nodoc:
      def initialize(name, block)
        super(name)
        @block = block
      end

      def add_to(proxy)
        value = @block.arity.zero? ? @block.call : @block.call(proxy)
        if Factory::Sequence === value
          raise SequenceAbuseError
        end
        proxy.set(name, value)
      end
    end

  end
end
