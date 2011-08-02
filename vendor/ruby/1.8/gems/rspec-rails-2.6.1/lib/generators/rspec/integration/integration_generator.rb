require 'generators/rspec'

module Rspec
  module Generators
    class IntegrationGenerator < Base
      class_option :request_specs,   :type => :boolean, :default => true,  :desc => "Generate request specs"
      class_option :webrat,          :type => :boolean, :default => false, :desc => "Use webrat methods/matchers"
      class_option :webrat_matchers, :type => :boolean, :default => false, :desc => "Use webrat methods/matchers (deprecated - use --webrat)"

      def generate_request_spec
        return unless options[:request_specs]

        template 'request_spec.rb',
                 File.join('spec/requests', class_path, "#{table_name}_spec.rb")
      end

    protected

      def webrat?
        RSpec.deprecate("the --webrat-matchers option", "--webrat") if options[:webrat_matchers]
        options[:webrat] || options[:webrat_matchers]
      end

    end
  end
end
