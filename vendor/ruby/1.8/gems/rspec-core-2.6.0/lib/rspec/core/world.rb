module RSpec
  module Core
    class World

      module Describable
        PROC_HEX_NUMBER = /0x[0-9a-f]+@/
        PROJECT_DIR = File.expand_path('.')

        def description
          reject { |k, v| RSpec::Core::Configuration::CONDITIONAL_FILTERS[k] == v }.inspect.gsub(PROC_HEX_NUMBER, '').gsub(PROJECT_DIR, '.').gsub(' (lambda)','')
        end

        def empty_without_conditional_filters?
          reject { |k, v| RSpec::Core::Configuration::CONDITIONAL_FILTERS[k] == v }.empty?
        end

        def reject
          super rescue {}
        end

        def empty?
          super rescue false
        end
      end

      include RSpec::Core::Hooks

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

      def reset
        example_groups.clear
      end

      def register(example_group)
        example_groups << example_group
        example_group
      end

      def inclusion_filter
        @configuration.inclusion_filter.extend(Describable)
      end

      def exclusion_filter
        @configuration.exclusion_filter.extend(Describable)
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
        declaration_line_numbers.sort.inject(nil) do |highest_prior_declaration_line, line|
          line <= filter_line ? line : highest_prior_declaration_line
        end
      end

      def reporter
        @configuration.reporter
      end

      def announce_filters
        filter_announcements = []

        if @configuration.run_all_when_everything_filtered? && example_count.zero?
          reporter.message( "No examples matched #{inclusion_filter.description}. Running all.")
          filtered_examples.clear
          @configuration.clear_inclusion_filter
        end

        announce_inclusion_filter filter_announcements
        announce_exclusion_filter filter_announcements

        if example_count.zero?
          example_groups.clear
          if filter_announcements.empty?
            reporter.message("No examples found.")
          elsif inclusion_filter
            message = "No examples matched #{inclusion_filter.description}."
            if @configuration.run_all_when_everything_filtered?
              message << " Running all."
            end
            reporter.message(message)
          elsif exclusion_filter
            reporter.message(
              "No examples were matched. Perhaps #{exclusion_filter.description} is excluding everything?")
          end
        elsif !filter_announcements.empty?
          reporter.message("Run filtered #{filter_announcements.join(', ')}")
        end
      end

      def announce_inclusion_filter(announcements)
        if inclusion_filter
          announcements << "including #{inclusion_filter.description}"
        end
      end

      def announce_exclusion_filter(announcements)
        unless exclusion_filter.empty_without_conditional_filters?
          announcements << "excluding #{exclusion_filter.description}"
        end
      end

      def find_hook(hook, scope, group, example = nil)
        @configuration.find_hook(hook, scope, group, example)
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
