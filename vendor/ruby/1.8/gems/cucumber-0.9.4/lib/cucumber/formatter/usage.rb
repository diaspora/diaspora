require 'cucumber/formatter/progress'
require 'cucumber/step_definition_light'

module Cucumber
  module Formatter
    class Usage < Progress
      include Console

      class StepDefKey < StepDefinitionLight
        attr_accessor :mean_duration, :status
      end

      def initialize(step_mother, path_or_io, options)
        @step_mother = step_mother
        @io = ensure_io(path_or_io, "usage")
        @options = options
        @stepdef_to_match = Hash.new{|h,stepdef_key| h[stepdef_key] = []}
      end

      def before_step(step)
        @step = step
        @start_time = Time.now
      end

      def before_step_result(*args)
        @duration = Time.now - @start_time
      end

      def after_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background)
        if step_match.name.nil? # nil if it's from a scenario outline
          stepdef_key = StepDefKey.new(step_match.step_definition.regexp_source, step_match.step_definition.file_colon_line)

          @stepdef_to_match[stepdef_key] << {
            :keyword => keyword, 
            :step_match => step_match, 
            :status => status, 
            :file_colon_line => @step.file_colon_line,
            :duration => @duration
          }
        end
        super
      end

      def print_summary(features)
        add_unused_stepdefs
        aggregate_info

        if @options[:dry_run]
          keys = @stepdef_to_match.keys.sort {|a,b| a.regexp_source <=> b.regexp_source}
        else
          keys = @stepdef_to_match.keys.sort {|a,b| a.mean_duration <=> b.mean_duration}.reverse
        end

        keys.each do |stepdef_key|
          print_step_definition(stepdef_key)

          if @stepdef_to_match[stepdef_key].any?
            print_steps(stepdef_key)
          else
            @io.puts("  " + format_string("NOT MATCHED BY ANY STEPS", :failed))
          end
        end
        @io.puts
        super
      end

      def print_step_definition(stepdef_key)
        @io.print format_string(sprintf("%.7f", stepdef_key.mean_duration), :skipped) + " " unless @options[:dry_run]
        @io.print format_string(stepdef_key.regexp_source, stepdef_key.status)
        if @options[:source]
          indent = max_length - stepdef_key.regexp_source.unpack('U*').length
          line_comment = "   # #{stepdef_key.file_colon_line}".indent(indent)
          @io.print(format_string(line_comment, :comment))
        end
        @io.puts
      end

      def print_steps(stepdef_key)
        @stepdef_to_match[stepdef_key].each do |step|
          @io.print "  "
          @io.print format_string(sprintf("%.7f", step[:duration]), :skipped) + " " unless @options[:dry_run]
          @io.print format_step(step[:keyword], step[:step_match], step[:status], nil)
          if @options[:source]
            indent = max_length - (step[:keyword].unpack('U*').length + step[:step_match].format_args.unpack('U*').length)
            line_comment = " # #{step[:file_colon_line]}".indent(indent)
            @io.print(format_string(line_comment, :comment))
          end
          @io.puts
        end
      end

      def max_length
        [max_stepdef_length, max_step_length].compact.max
      end

      def max_stepdef_length
        @stepdef_to_match.keys.flatten.map{|key| key.regexp_source.unpack('U*').length}.max
      end

      def max_step_length
        @stepdef_to_match.values.to_a.flatten.map do |step|
          step[:keyword].unpack('U*').length + step[:step_match].format_args.unpack('U*').length
        end.max
      end

      def aggregate_info
        @stepdef_to_match.each do |key, steps|
          if steps.empty?
            key.status = :skipped
            key.mean_duration = 0
          else
            key.status = Ast::StepInvocation.worst_status(steps.map{|step| step[:status]})
            total_duration = steps.inject(0) {|sum, step| step[:duration] + sum}
            key.mean_duration = total_duration / steps.length
          end
        end
      end

      def add_unused_stepdefs
        @step_mother.unmatched_step_definitions.each do |step_definition|
          stepdef_key = StepDefKey.new(step_definition.regexp_source, step_definition.file_colon_line)
          @stepdef_to_match[stepdef_key] = []
        end
      end
    end
  end
end