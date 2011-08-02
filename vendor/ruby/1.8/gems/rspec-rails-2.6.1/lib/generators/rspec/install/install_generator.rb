module Rspec
  module Generators
    class InstallGenerator < Rails::Generators::Base

      desc <<DESC
Description:
    Copy rspec files to your application.
DESC

      def self.source_root
        @source_root ||= File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
      end

      def copy_dot_rspec
        template '.rspec'
      end

      def copy_spec_files
        directory 'spec'
      end

    end
  end
end
