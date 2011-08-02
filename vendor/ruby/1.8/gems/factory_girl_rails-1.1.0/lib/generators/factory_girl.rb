require 'rails/generators/named_base'

module FactoryGirl
  module Generators
    class Base < Rails::Generators::NamedBase #:nodoc:
      def self.source_root
        @_factory_girl_source_root ||= File.expand_path(File.join(File.dirname(__FILE__), 'factory_girl', generator_name, 'templates'))
      end
    end
  end
end