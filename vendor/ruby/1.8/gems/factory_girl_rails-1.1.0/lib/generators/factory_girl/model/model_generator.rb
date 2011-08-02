require 'generators/factory_girl'

module FactoryGirl
  module Generators
    class ModelGenerator < Base
      argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"
      class_option :dir, :type => :string, :default => "test/factories", :desc => "The directory where the factories should go"
      
      def create_fixture_file
        template 'fixtures.rb', File.join(options[:dir], "#{table_name}.rb")
      end
    end
  end
end
