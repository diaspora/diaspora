require 'generators/rspec'

module Rspec
  module Generators
    class MailerGenerator < Base
      argument :actions, :type => :array, :default => [], :banner => "method method"

      def generate_mailer_spec
        template "mailer_spec.rb", File.join('spec/mailers', class_path, "#{file_name}_spec.rb")
      end

      def generate_fixtures_files
        actions.each do |action|
          @action, @path = action, File.join(file_path, action)
          template "fixture", File.join("spec/fixtures", @path)
        end
      end
    end
  end
end
