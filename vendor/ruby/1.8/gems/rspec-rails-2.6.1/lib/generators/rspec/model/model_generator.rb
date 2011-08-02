require 'generators/rspec'

module Rspec
  module Generators
    class ModelGenerator < Base
      argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"
      class_option :fixture, :type => :boolean

      def create_model_spec
        template 'model_spec.rb', File.join('spec/models', class_path, "#{file_name}_spec.rb")
      end

      hook_for :fixture_replacement

      def create_fixture_file
        if options[:fixture] && options[:fixture_replacement].nil?
          template 'fixtures.yml', File.join('spec/fixtures', "#{table_name}.yml")
        end
      end
    end
  end
end
