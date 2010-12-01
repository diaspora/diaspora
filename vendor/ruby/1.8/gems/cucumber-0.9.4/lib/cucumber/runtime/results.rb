module Cucumber
  class Runtime
    
    class Results
      def initialize(configuration)
        @configuration = configuration

        # Optimization - quicker lookup.
        @inserted_steps = {}
        @inserted_scenarios = {}
      end

      def configure(new_configuration)
        @configuration = Configuration.parse(new_configuration)
      end

      def step_visited(step) #:nodoc:
        step_id = step.object_id

        unless @inserted_steps.has_key?(step_id)
          @inserted_steps[step_id] = step
          steps.push(step)
        end
      end
      
      def scenario_visited(scenario) #:nodoc:
        scenario_id = scenario.object_id

        unless @inserted_scenarios.has_key?(scenario_id)
          @inserted_scenarios[scenario_id] = scenario
          scenarios.push(scenario)
        end
      end
      
      def steps(status = nil) #:nodoc:
        @steps ||= []
        if(status)
          @steps.select{|step| step.status == status}
        else
          @steps
        end
      end
      
      def scenarios(status = nil) #:nodoc:
        @scenarios ||= []
        if(status)
          @scenarios.select{|scenario| scenario.status == status}
        else
          @scenarios
        end
      end
      
      def failure?
        if @configuration.wip?
          scenarios(:passed).any?
        else
          scenarios(:failed).any? ||
          (@configuration.strict? && (steps(:undefined).any? || steps(:pending).any?))
        end
      end
    end
    
  end
end