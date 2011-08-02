require 'digest/md5'
require 'fileutils'
module FixtureBuilder
  class << self
    def configuration
      @configuration ||= FixtureBuilder::Configuration.new
    end

    def configure
      yield configuration
    end
  end

  class Configuration
    attr_accessor :select_sql, :delete_sql, :skip_tables, :files_to_check, :record_name_fields, :fixture_builder_file, :after_build

    SCHEMA_FILES = ['db/schema.rb', 'db/development_structure.sql', 'db/test_structure.sql', 'db/production_structure.sql']

    def initialize
      @custom_names = {}
      @file_hashes = file_hashes
    end

    def include(*args)
      class_eval do
        args.each do |arg|
          include arg
        end
      end
    end

    def select_sql
      @select_sql ||= "SELECT * FROM %s"
    end

    def delete_sql
      @delete_sql ||= "DELETE FROM %s"
    end

    def skip_tables
      @skip_tables ||= %w{ schema_migrations }
    end

    def files_to_check
      @files_to_check ||= schema_definition_files
    end

    def schema_definition_files
      Dir['db/*'].inject([]) do |result, file|
        result << file if SCHEMA_FILES.include?(file)
        result
      end
    end

    def files_to_check=(files)
      @files_to_check = files
      @file_hashes = file_hashes
      @files_to_check
    end

    def record_name_fields
      @record_name_fields ||= %w{ unique_name display_name name title username login }
    end

    def fixture_builder_file
      @fixture_builder_file ||= Rails.root.join('tmp', 'fixture_builder.yml')
    end

    def factory(&block)
      return unless rebuild_fixtures?
      say "Building fixtures"
      delete_tables
      delete_yml_files
      surface_errors { instance_eval(&block) }
      FileUtils.rm_rf(Rails.root.join(spec_or_test_dir, 'fixtures', '*.yml'))
      dump_empty_fixtures_for_all_tables
      dump_tables
      write_config
      after_build.call if after_build
    end

    def name(custom_name, *model_objects)
      raise "Cannot name an object blank" unless custom_name.present?
      model_objects.each do |model_object|
        raise "Cannot name a blank object" unless model_object.present?
        key = [model_object.class.table_name, model_object.id]
        raise "Cannot set name for #{key.inspect} object twice" if @custom_names[key]
        @custom_names[key] = custom_name
        model_object
      end
    end

    private

    def say(*messages)
      puts messages.map { |message| "=> #{message}" }
    end

    def surface_errors
      yield
    rescue Object => error
      puts
      say "There was an error building fixtures", error.inspect
      puts
      puts error.backtrace
      puts
      exit!
    end

    def delete_tables
      tables.each { |t| ActiveRecord::Base.connection.delete(delete_sql % ActiveRecord::Base.connection.quote_table_name(t)) }
    end

    def delete_yml_files
      FileUtils.rm(Dir.glob(fixtures_dir('*.yml')))
    end

    def tables
      ActiveRecord::Base.connection.tables - skip_tables
    end

    def names_from_ivars!
      instance_values.each do |var, value|
        name(var, value) if value.is_a? ActiveRecord::Base
      end
    end

    def record_name(record_hash)
      key = [@table_name, record_hash['id'].to_i]
      @record_names << (name = @custom_names[key] || inferred_record_name(record_hash))
      name.to_s
    end

    def inferred_record_name(record_hash)
      record_name_fields.each do |try|
        if name = record_hash[try]
          inferred_name = name.underscore.gsub(/\W/, ' ').squeeze(' ').tr(' ', '_')
          count = @record_names.select { |name| name.to_s.starts_with?(inferred_name) }.size
          # CHANGED == to starts_with?
          return count.zero? ? inferred_name : "#{inferred_name}_#{count}"
        end
      end

      "#{@table_name}_#{@row_index.succ!}"
    end

    def dump_empty_fixtures_for_all_tables
      tables.each do |table_name|
        @table_name = table_name
        write_fixture_file({})
      end
    end

    def dump_tables
      fixtures = tables.inject([]) do |files, table_name|
        @table_name = table_name
        table_klass = @table_name.classify.constantize rescue nil
        if table_klass
          rows = table_klass.unscoped.all.collect(&:attributes)
        else
          rows = ActiveRecord::Base.connection.select_all(select_sql % ActiveRecord::Base.connection.quote_table_name(@table_name))
        end
        next files if rows.empty?

        @row_index      = '000'
        @record_names = []
        fixture_data = rows.inject({}) do |hash, record|
          hash.merge(record_name(record) => record)
        end

        write_fixture_file fixture_data

        files + [File.basename(fixture_file)]
      end
      say "Built #{fixtures.to_sentence}"
    end

    def write_fixture_file(fixture_data)
      File.open(fixture_file, 'w') do |file|
        file.write fixture_data.to_yaml
      end
    end

    def fixture_file
      fixtures_dir("#{@table_name}.yml")
    end

    def fixtures_dir(path = '')
      File.join(Rails.root, spec_or_test_dir, 'fixtures', path)
    end

    def spec_or_test_dir
      File.exists?(File.join(Rails.root, 'spec')) ? 'spec' : 'test'
    end

    def file_hashes
      files_to_check.inject({}) do |hash, filename|
        hash[filename] = Digest::MD5.hexdigest(File.read(filename))        
        hash
      end
    end

    def read_config
      return {} unless File.exist?(fixture_builder_file)
      YAML.load_file(fixture_builder_file)
    end

    def write_config
      FileUtils.mkdir_p(File.dirname(fixture_builder_file))
      File.open(fixture_builder_file, 'w') { |f| f.write(YAML.dump(@file_hashes)) }
    end

    def rebuild_fixtures?
      @file_hashes != read_config
    end
  end

  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/fixture_builder.rake"
    end
  end
end
