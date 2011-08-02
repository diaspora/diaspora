require 'rails/generators/named_base'

module Rspec
  module Generators
    class Base < Rails::Generators::NamedBase #:nodoc:
      def self.source_root
        @_rspec_source_root ||= File.expand_path(File.join(File.dirname(__FILE__), 'rspec', generator_name, 'templates'))
      end
    end
  end
end

module Rails
  module Generators
    class GeneratedAttribute #:nodoc:
      def input_type
        @input_type ||= if type == :text
          "textarea"
        else
          "input"
        end
      end
    end
  end
end
