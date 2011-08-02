$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH << File.join(File.dirname(__FILE__))

require 'rubygems'
require 'rspec'
require 'rspec/autorun'
require 'rr'

require 'factory_girl'

module RR
  module Adapters
    module Rspec
      def self.included(mod)
        RSpec.configuration.backtrace_clean_patterns.push(RR::Errors::BACKTRACE_IDENTIFIER)
      end
    end
  end
end

RSpec.configure do |config|
  config.mock_framework = :rr
  RSpec::Core::ExampleGroup.send(:include, RR::Adapters::Rspec)
  config.after do
    FactoryGirl.factories.clear
    FactoryGirl.sequences.clear
  end
end

module DefinesConstants
  def self.included(example_group)
    example_group.class_eval do
      before do
        @defined_constants ||= []
        @created_tables ||= []
      end

      after do
        @defined_constants.reverse.each do |path|
          namespace, class_name = *constant_path(path)
          namespace.send(:remove_const, class_name)
        end
        @defined_constants.clear

        @created_tables.each do |table_name|
          ActiveRecord::Base.
            connection.
            execute("DROP TABLE IF EXISTS #{table_name}")
        end
        @created_tables.clear
      end

      def define_class(path, base = Object, &block)
        namespace, class_name = *constant_path(path)
        klass = Class.new(base)
        namespace.const_set(class_name, klass)
        klass.class_eval(&block) if block_given?
        @defined_constants << path
        klass
      end

      def define_model(name, columns = {}, &block)
        model = define_class(name, ActiveRecord::Base, &block)
        create_table(model.table_name) do |table|
          columns.each do |name, type|
            table.column name, type
          end
        end
        model
      end

      def create_table(table_name, &block)
        connection = ActiveRecord::Base.connection

        begin
          connection.execute("DROP TABLE IF EXISTS #{table_name}")
          connection.create_table(table_name, &block)
          @created_tables << table_name
          connection
        rescue Exception => exception
          connection.execute("DROP TABLE IF EXISTS #{table_name}")
          raise exception
        end
      end

      def constant_path(constant_name)
        names = constant_name.split('::')
        class_name = names.pop
        namespace = names.inject(Object) { |result, name| result.const_get(name) }
        [namespace, class_name]
      end
    end
  end
end

