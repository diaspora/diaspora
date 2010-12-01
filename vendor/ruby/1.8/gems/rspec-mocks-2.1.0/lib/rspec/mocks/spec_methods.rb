module RSpec
  module Mocks
    module ExampleMethods
      include RSpec::Mocks::ArgumentMatchers

      # Creates an instance of RSpec::Mocks::Mock.
      #
      # +name+ is used for failure reporting, so you should use the role that
      # the mock is playing in the example.
      #
      # Use +stubs+ to declare one or more method stubs in one statement.
      #
      # == Examples
      #
      #   book = double("book", :title => "The RSpec Book")
      #   book.title => "The RSpec Book"
      #
      #   card = double("card", :suit => "Spades", :rank => "A"
      #   card.suit => "Spades"
      #   card.rank => "A"
      def double(*args)
        declare_double('Double', *args)
      end

      # Just like double, but use double
      def mock(*args)
        declare_double('Mock', *args)
      end

      # Just like double, but use double
      def stub(*args)
        declare_double('Stub', *args)
      end

      # Disables warning messages about expectations being set on nil.
      #
      # By default warning messages are issued when expectations are set on nil.  This is to
      # prevent false-positives and to catch potential bugs early on.
      def allow_message_expectations_on_nil
        Proxy.allow_message_expectations_on_nil
      end

    private
      
      def declare_double(declared_as, *args)
        args << {} unless Hash === args.last
        args.last[:__declared_as] = declared_as
        RSpec::Mocks::Mock.new(*args)
      end

    end
  end
end
