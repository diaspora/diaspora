require 'gherkin/rubify'
require 'gherkin/i18n'
require 'cucumber/configuration'
require 'cucumber/language_support/language_methods'
require 'cucumber/formatter/duration'
require 'cucumber/runtime/user_interface'
require 'cucumber/runtime/features_loader'
require 'cucumber/runtime/results'
require 'cucumber/runtime/support_code'

module Cucumber
  # This is the meaty part of Cucumber that ties everything together.
  class Runtime
    attr_reader :results
    
    include Formatter::Duration
    include Runtime::UserInterface

    def initialize(configuration = Configuration.default)
      require 'cucumber/core_ext/disable_mini_and_test_unit_autorun'
      @current_scenario = nil
      @configuration = Configuration.parse(configuration)
      @support_code = SupportCode.new(self, @configuration)
      @results = Results.new(@configuration)
    end
    
    # Allows you to take an existing runtime and change it's configuration
    def configure(new_configuration)
      @configuration = Configuration.parse(new_configuration)
      @support_code.configure(@configuration)
      @results.configure(@configuration)
    end
    
    def load_programming_language(language)
      @support_code.load_programming_language(language)
    end
    
    def run!
      load_step_definitions
      fire_after_configuration_hook

      tree_walker = @configuration.build_tree_walker(self)
      self.visitor = tree_walker # Ugly circular dependency, but needed to support World#puts
      
      tree_walker.visit_features(features)
    end
    
    def features_paths
      @configuration.paths
    end

    def step_visited(step) #:nodoc:
      @results.step_visited(step)
    end

    def scenarios(status = nil)
      @results.scenarios(status)
    end

    def steps(status = nil)
      @results.steps(status)
    end

    def step_match(step_name, name_to_report=nil) #:nodoc:
      @support_code.step_match(step_name, name_to_report)
    end

    def unmatched_step_definitions
      @support_code.unmatched_step_definitions
    end

    def snippet_text(step_keyword, step_name, multiline_arg_class) #:nodoc:
      @support_code.snippet_text(Gherkin::I18n.code_keyword_for(step_keyword), step_name, multiline_arg_class)
    end

    def with_hooks(scenario, skip_hooks=false)
      around(scenario, skip_hooks) do
        before_and_after(scenario, skip_hooks) do
          yield scenario
        end
      end
    end

    def around(scenario, skip_hooks=false, &block) #:nodoc:
      if skip_hooks
        yield
        return
      end

      @support_code.around(scenario, block)
    end

    def before_and_after(scenario, skip_hooks=false) #:nodoc:
      before(scenario) unless skip_hooks
      yield scenario
      after(scenario) unless skip_hooks
      @results.scenario_visited(scenario)
    end

    def before(scenario) #:nodoc:
      return if @configuration.dry_run? || @current_scenario
      @current_scenario = scenario
      @support_code.fire_hook(:before, scenario)
    end

    def after(scenario) #:nodoc:
      @current_scenario = nil
      return if @configuration.dry_run?
      @support_code.fire_hook(:after, scenario)
    end

    def after_step #:nodoc:
      return if @configuration.dry_run?
      @support_code.fire_hook(:execute_after_step, @current_scenario)
    end

    def unknown_programming_language?
      @support_code.unknown_programming_language?
    end

  private

    def fire_after_configuration_hook #:nodoc
      @support_code.fire_hook(:after_configuration, @configuration)
    end

    def features
      loader = Runtime::FeaturesLoader.new(
        @configuration.feature_files, 
        @configuration.filters, 
        @configuration.tag_expression)
      loader.features
    end

    def load_step_definitions
      files = @configuration.support_to_load + @configuration.step_defs_to_load
      @support_code.load_files!(files)
    end

    def log
      Cucumber.logger
    end
  end

end