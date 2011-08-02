module Jasmine
  module Generators
    class ExamplesGenerator < Rails::Generators::Base

      def self.source_root
        @source_root ||= File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
      end

      def copy_example_files
        directory 'public'
        directory 'spec'
      end

      def app_name
        Rails.application.class.name
      end
    end
  end
end
