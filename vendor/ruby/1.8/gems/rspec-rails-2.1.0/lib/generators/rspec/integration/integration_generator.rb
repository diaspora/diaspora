require 'generators/rspec'

module Rspec
  module Generators
    class IntegrationGenerator < Base
      class_option :request_specs, :type => :boolean, :default => true,  :desc => "Generate request specs"

      def generate_request_spec
        return unless options[:request_specs]

        template 'request_spec.rb',
                 File.join('spec/requests', class_path, "#{table_name}_spec.rb")
      end
    end
  end
end
