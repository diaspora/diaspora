module RSpec
  module Core
    class World

      attr_reader :example_groups, :filtered_examples, :wants_to_quit
      attr_writer :wants_to_quit

      def initialize(configuration=RSpec.configuration)
        @configuration = configuration
        @example_groups = []
        @filtered_examples = Hash.new { |hash,group|
          hash[group] = begin
            examples = group.examples.dup
            examples = apply_exclusion_filters(examples, exclusion_filter) if exclusion_filter
            examples = apply_inclusion_filters(examples, inclusion_filter) if inclusion_filter
            examples.uniq
          end
        }
      end

      def register(example_group)
        example_groups << example_group
        example_group
      end

      def inclusion_filter
        @configuration.filter
      end

      def exclusion_filter
        @configuration.exclusion_filter
      end

      def configure_group(group)
        @configuration.configure_group(group)
      end

      def shared_example_groups
        @shared_example_groups ||= {}
      end

      def example_count
        example_groups.collect {|g| g.descendants}.flatten.inject(0) { |sum, g| sum += g.filtered_examples.size }
      end

      def apply_inclusion_filters(examples, conditions={})
        examples.select(&apply?(:any?, conditions))
      end

      alias_method :find, :apply_inclusion_filters

      def apply_exclusion_filters(examples, conditions={})
        examples.reject(&apply?(:any?, conditions))
      end

      def preceding_declaration_line(filter_line)
        declaration_line_numbers.inject(nil) do |highest_prior_declaration_line, line|
          line <= filter_line ? line : highest_prior_declaration_line
        end
      end

      def announce_inclusion_filter
        if inclusion_filter
          if @configuration.run_all_when_everything_filtered? && RSpec.world.example_count.zero?
            @configuration.reporter.message "No examples were matched by #{inclusion_filter.inspect}, running all"
            @configuration.clear_inclusion_filter
            filtered_examples.clear
          else
            @configuration.reporter.message "Run filtered using #{inclusion_filter.inspect}"
          end
        end
      end
      
      def announce_exclusion_filter
        if exclusion_filter && RSpec.world.example_count.zero?
          @configuration.reporter.message(
            "No examples were matched. Perhaps #{exclusion_filter.inspect} is excluding everything?")
          example_groups.clear
        end
      end

      include RSpec::Core::Hooks

      def find_hook(hook, scope, group)
        @configuration.find_hook(hook, scope, group)
      end

    private

      def apply?(predicate, conditions)
        lambda {|example| example.metadata.apply?(predicate, conditions)}
      end

      def declaration_line_numbers
        @line_numbers ||= example_groups.inject([]) do |lines, g|
          lines + g.declaration_line_numbers
        end
      end

    end
  end
end
