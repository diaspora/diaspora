require 'socket'
require 'json'
require 'cucumber/wire_support/connection'
require 'cucumber/wire_support/configuration'
require 'cucumber/wire_support/wire_packet'
require 'cucumber/wire_support/wire_exception'
require 'cucumber/wire_support/wire_step_definition'

module Cucumber
  module WireSupport
    
    # The wire-protocol (lanugage independent) implementation of the programming 
    # language API.
    class WireLanguage
      include LanguageSupport::LanguageMethods

      def initialize(step_mother)
        @connections = []
      end
      
      def alias_adverbs(adverbs)
      end

      def load_code_file(wire_file)
        config = Configuration.new(wire_file)
        @connections << Connection.new(config)
      end
      
      def snippet_text(code_keyword, step_name, multiline_arg_class)
        snippets = @connections.map do |remote| 
          remote.snippet_text(code_keyword, step_name, multiline_arg_class.to_s)
        end
        snippets.flatten.join("\n")
      end
      
      def step_matches(step_name, formatted_step_name)
        @connections.map{ |c| c.step_matches(step_name, formatted_step_name)}.flatten
      end
      
      protected
      
      def begin_scenario(scenario)
        @connections.each { |c| c.begin_scenario(scenario) }
        @current_scenario = scenario
      end
      
      def end_scenario
        scenario = @current_scenario
        @connections.each { |c| c.end_scenario(scenario) }
        @current_scenario = nil
      end
    end
  end
end
