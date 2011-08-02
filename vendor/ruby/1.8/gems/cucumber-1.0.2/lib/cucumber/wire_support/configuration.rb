require 'yaml'
require 'erb'

module Cucumber
  module WireSupport
    class Configuration
      attr_reader :host, :port
      
      def initialize(wire_file)
        params = YAML.load(ERB.new(File.read(wire_file)).result)
        @host = params['host']
        @port = params['port']
        @timeouts = default_timeouts.merge(params['timeout'] || {})
      end
      
      def timeout(message = nil)
        return @timeouts[message.to_s] || 3
      end
      
      private
      
      def default_timeouts
        {
          'invoke' => 120,
          'begin_scenario' => 120,
          'end_scenario' => 120
        }
      end
    end
  end
end