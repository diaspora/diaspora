module Cucumber
  module Formatter
    module Summary

      def scenario_summary(step_mother, &block)
        scenarios_proc = lambda{|status| step_mother.scenarios(status)}
        dump_count(step_mother.scenarios.length, "scenario") + dump_status_counts(scenarios_proc, &block)
      end

      def step_summary(step_mother, &block)
        steps_proc = lambda{|status| step_mother.steps(status)}
        dump_count(step_mother.steps.length, "step") + dump_status_counts(steps_proc, &block)
      end

      private

      def dump_status_counts(find_elements_proc)
        counts = [:failed, :skipped, :undefined, :pending, :passed].map do |status|
          elements = find_elements_proc.call(status)
          elements.any? ? yield("#{elements.length} #{status.to_s}", status) : nil
        end.compact
        if counts.any?
          " (#{counts.join(', ')})"
        else
          ""
        end
      end

      def dump_count(count, what, state=nil)
        [count, state, "#{what}#{count == 1 ? '' : 's'}"].compact.join(" ")
      end

    end
  end
end
