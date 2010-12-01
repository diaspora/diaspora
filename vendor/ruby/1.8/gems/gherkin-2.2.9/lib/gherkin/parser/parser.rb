require 'gherkin/i18n'
require 'gherkin/lexer/i18n_lexer'
require 'gherkin/native'
require 'gherkin/listener/formatter_listener'

module Gherkin
  module Parser
    class ParseError < StandardError
      def initialize(state, new_state, expected_states, uri, line)
        super("Parse error at #{uri}:#{line}. Found #{new_state} when expecting one of: #{expected_states.join(', ')}. (Current state: #{state}).")
      end
    end

    class Parser
      native_impl('gherkin')

      # Initialize the parser. +machine_name+ refers to a state machine table.
      def initialize(formatter, raise_on_error=true, machine_name='root', force_ruby=false)
        @formatter = formatter
        @listener = Listener::FormatterListener.new(@formatter)
        @raise_on_error = raise_on_error
        @machine_name = machine_name
        @machines = []
        push_machine(@machine_name)
        @lexer = Gherkin::Lexer::I18nLexer.new(self, force_ruby)
      end

      def parse(gherkin, feature_uri, line_offset)
        @formatter.uri(feature_uri)
        @line_offset = line_offset
        @lexer.scan(gherkin)
      end

      def i18n_language
        @lexer.i18n_language
      end

      def errors
        @lexer.errors
      end

      # Doesn't yet fall back to super
      def method_missing(method, *args)
        # TODO: Catch exception and call super
        event(method.to_s, args[-1])
        @listener.__send__(method, *args)
        if method == :eof
          pop_machine
          push_machine(@machine_name)
        end
      end

      def event(ev, line)
        l = line ? @line_offset+line : nil
        machine.event(ev, l) do |state, legal_events|
          if @raise_on_error
            raise ParseError.new(state, ev, legal_events, @feature_uri, l)
          else
            # Only used for testing
            @listener.syntax_error(state, ev, legal_events, @feature_uri, l)
          end
        end
      end

      def push_machine(name)
        @machines.push(Machine.new(self, name))
      end

      def pop_machine
        @machines.pop
      end

      def machine
        @machines[-1]
      end

      def expected
        machine.expected
      end

      def force_state(state)
        machine.instance_variable_set('@state', state)
      end

      class Machine
        def initialize(parser, name)
          @parser = parser
          @name = name
          @transition_map = transition_map(name)
          @state = name
        end

        def event(ev, line)
          states = @transition_map[@state]
          raise "Unknown state: #{@state.inspect} for machine #{@name}" if states.nil?
          new_state = states[ev]
          case new_state
          when "E"
            yield @state, expected
          when /push\((.+)\)/
            @parser.push_machine($1)
            @parser.event(ev, line)
          when "pop()"
            @parser.pop_machine()
            @parser.event(ev, line)
          else
            raise "Unknown transition: #{ev.inspect} among #{states.inspect} for machine #{@name}" if new_state.nil?
            @state = new_state
          end
        end

        def expected
          allowed = @transition_map[@state].find_all { |_, action| action != "E" }
          allowed.collect { |state| state[0] }.sort - ['eof']
        end

        private

        @@transition_maps = {}

        def transition_map(name)
          @@transition_maps[name] ||= build_transition_map(name)
        end

        def build_transition_map(name)
          table = transition_table(name)
          events = table.shift[1..-1]
          table.inject({}) do |machine, actions|
            state = actions.shift
            machine[state] = Hash[*events.zip(actions).flatten]
            machine
          end
        end

        def transition_table(name)
          state_machine_reader = StateMachineReader.new
          lexer = Gherkin::I18n.new('en').lexer(state_machine_reader)
          machine = File.dirname(__FILE__) + "/#{name}.txt"
          lexer.scan(File.read(machine))
          state_machine_reader.rows
        end

        class StateMachineReader
          attr_reader :rows

          def initialize
            @rows = []
          end

          def uri(uri)
          end

          def row(row, line_number)
            @rows << row
          end

          def eof
          end
        end

      end
    end
  end
end
