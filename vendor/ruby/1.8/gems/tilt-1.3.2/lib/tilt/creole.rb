require 'tilt/template'

module Tilt
  # Creole implementation. See:
  # http://www.wikicreole.org/
  class CreoleTemplate < Template
    def self.engine_initialized?
      defined? ::Creole
    end

    def initialize_engine
      require_template_library 'creole'
    end

    def prepare
      opts = {}
      [:allowed_schemes, :extensions, :no_escape].each do |k|
        opts[k] = options[k] if options[k]
      end
      @engine = Creole::Parser.new(data, opts)
      @output = nil
    end

    def evaluate(scope, locals, &block)
      @output ||= @engine.to_html
    end
  end
end
