module Jasmine
  module Generators
    class InstallGenerator < Rails::Generators::Base

      def self.source_root
        @source_root ||= File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
      end

      def copy_spec_files
        directory 'spec'
      end

      def app_name
        Rails.application.class.name
      end
    end
  end
end
