module RSpec
  module Mocks

    # ArgumentMatchers are messages that you can include in message
    # expectations to match arguments against a broader check than simple
    # equality.
    #
    # With the exception of any_args() and no_args(), the matchers
    # are all positional - they match against the arg in the given position.
    module ArgumentMatchers

      class AnyArgsMatcher
        def description
          "any args"
        end
      end

      class AnyArgMatcher
        def initialize(ignore)
        end

        def ==(other)
          true
        end
      end

      class NoArgsMatcher
        def description
          "no args"
        end
      end

      class RegexpMatcher
        def initialize(regexp)
          @regexp = regexp
        end

        def ==(value)
          return value =~ @regexp unless value.is_a?(Regexp)
          value == @regexp
        end
      end

      class BooleanMatcher
        def initialize(ignore)
        end

        def ==(value)
          TrueClass === value || FalseClass === value
        end
      end

      class HashIncludingMatcher
        def initialize(expected)
          @expected = expected
        end

        def ==(actual)
          @expected.each do | key, value |
            return false unless actual.has_key?(key) && value == actual[key]
          end
          true
        rescue NoMethodError => ex
          return false
        end

        def description
          "hash_including(#{@expected.inspect.sub(/^\{/,"").sub(/\}$/,"")})"
        end
      end
      
      class HashNotIncludingMatcher
        def initialize(expected)
          @expected = expected
        end

        def ==(actual)
          @expected.each do | key, value |
            return false if actual.has_key?(key) && value == actual[key]
          end
          true
        rescue NoMethodError => ex
          return false
        end

        def description
          "hash_not_including(#{@expected.inspect.sub(/^\{/,"").sub(/\}$/,"")})"
        end
      end
      
      class DuckTypeMatcher
        def initialize(*methods_to_respond_to)
          @methods_to_respond_to = methods_to_respond_to
        end

        def ==(value)
          @methods_to_respond_to.all? { |sym| value.respond_to?(sym) }
        end
      end

      class MatcherMatcher
        def initialize(matcher)
          @matcher = matcher
        end

        def ==(value)
          @matcher.matches?(value)
        end
      end

      class EqualityProxy
        def initialize(given)
          @given = given
        end

        def ==(expected)
          @given == expected
        end
      end
      
      class InstanceOf
        def initialize(klass)
          @klass = klass
        end
        
        def ==(actual)
          actual.instance_of?(@klass)
        end
      end
      
      class KindOf
        def initialize(klass)
          @klass = klass
        end
        
        def ==(actual)
          actual.kind_of?(@klass)
        end
      end

      # :call-seq:
      #   object.should_receive(:message).with(any_args())
      #
      # Passes if object receives :message with any args at all. This is
      # really a more explicit variation of object.should_receive(:message)
      def any_args
        AnyArgsMatcher.new
      end
      
      # :call-seq:
      #   object.should_receive(:message).with(anything())
      #
      # Passes as long as there is an argument.
      def anything
        AnyArgMatcher.new(nil)
      end
      
      # :call-seq:
      #   object.should_receive(:message).with(no_args)
      #
      # Passes if no arguments are passed along with the message
      def no_args
        NoArgsMatcher.new
      end
      
      # :call-seq:
      #   object.should_receive(:message).with(duck_type(:hello))
      #   object.should_receive(:message).with(duck_type(:hello, :goodbye))
      #
      # Passes if the argument responds to the specified messages.
      #
      # == Examples
      #
      #   array = []
      #   display = double('display')
      #   display.should_receive(:present_names).with(duck_type(:length, :each))
      #   => passes
      def duck_type(*args)
        DuckTypeMatcher.new(*args)
      end

      # :call-seq:
      #   object.should_receive(:message).with(boolean())
      #
      # Passes if the argument is boolean.
      def boolean
        BooleanMatcher.new(nil)
      end
      
      # :call-seq:
      #   object.should_receive(:message).with(hash_including(:key => val))
      #   object.should_receive(:message).with(hash_including(:key))
      #   object.should_receive(:message).with(hash_including(:key, :key2 => val2))
      # Passes if the argument is a hash that includes the specified key(s) or key/value
      # pairs. If the hash includes other keys, it will still pass.
      def hash_including(*args)
        HashIncludingMatcher.new(anythingize_lonely_keys(*args))
      end
      
      # :call-seq:
      #   object.should_receive(:message).with(hash_not_including(:key => val))
      #   object.should_receive(:message).with(hash_not_including(:key))
      #   object.should_receive(:message).with(hash_not_including(:key, :key2 => :val2))
      #
      # Passes if the argument is a hash that doesn't include the specified key(s) or key/value
      def hash_not_including(*args)
        HashNotIncludingMatcher.new(anythingize_lonely_keys(*args))
      end
      
      # Passes if arg.instance_of?(klass)
      def instance_of(klass)
        InstanceOf.new(klass)
      end
      
      alias_method :an_instance_of, :instance_of
      
      # Passes if arg.kind_of?(klass)
      def kind_of(klass)
        KindOf.new(klass)
      end
      
      alias_method :a_kind_of, :kind_of
      
      private
      
      def anythingize_lonely_keys(*args)
        hash = args.last.class == Hash ? args.delete_at(-1) : {}
        args.each { | arg | hash[arg] = anything }
        hash
      end
    end
  end
end
