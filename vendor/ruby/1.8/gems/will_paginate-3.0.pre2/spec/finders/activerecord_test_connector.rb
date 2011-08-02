require 'active_record'
require 'active_record/version'
require 'active_record/fixtures'
require 'active_support/multibyte' # needed for Ruby 1.9.1

$query_count = $query_sql = nil

class ActiverecordTestConnector
  cattr_accessor :able_to_connect
  cattr_accessor :connected

  FIXTURES_PATH = File.expand_path('../../fixtures', __FILE__)

  # Set our defaults
  self.connected = false
  self.able_to_connect = true

  def self.setup
    unless self.connected || !self.able_to_connect
      setup_connection
      load_schema
      add_load_path FIXTURES_PATH
      self.connected = true
    end
  rescue Exception => e  # errors from ActiveRecord setup
    $stderr.puts "\nSkipping ActiveRecord tests: #{e}\n\n"
    self.able_to_connect = false
  end

  private
  
  def self.add_load_path(path)
    dep = defined?(ActiveSupport::Dependencies) ? ActiveSupport::Dependencies : ::Dependencies
    dep.autoload_paths.unshift path
  end

  def self.setup_connection
    db = ENV['DB'].blank?? 'sqlite3' : ENV['DB']
    
    configurations = YAML.load_file(File.expand_path('../../database.yml', __FILE__))
    raise "no configuration for '#{db}'" unless configurations.key? db
    configuration = configurations[db]
    
    ActiveRecord::Base.logger = Logger.new(STDOUT) if $0 == 'irb'
    puts "using #{configuration['adapter']} adapter"
    
    ActiveRecord::Base.configurations = { db => configuration }
    ActiveRecord::Base.establish_connection(db)
    prepare ActiveRecord::Base.connection
  end

  def self.load_schema
    ActiveRecord::Base.silence do
      ActiveRecord::Migration.verbose = false
      load File.join(FIXTURES_PATH, 'schema.rb')
    end
  end

  def self.prepare(conn)
    class << conn
      IGNORED_SQL = /^(?:PRAGMA|SELECT (?:currval|CAST|@@IDENTITY|@@ROWCOUNT)|SHOW FIELDS)\b/

      def execute_with_counting(sql, name = nil, &block)
        if $query_count and IGNORED_SQL !~ sql
          $query_count += 1
          $query_sql << sql
        end
        execute_without_counting(sql, name, &block)
      end

      alias_method_chain :execute, :counting
    end
  end
  
  def self.show_sql
    ActiveSupport::Notifications.subscribe('active_record.sql') do |*args|
      puts args.last[:sql]
    end
  end
  
  module FixtureSetup
    def fixtures(*tables)
      table_names = tables.map { |t| t.to_s }

      fixtures = Fixtures.create_fixtures ActiverecordTestConnector::FIXTURES_PATH, table_names
      @@loaded_fixtures = {}
      @@fixture_cache = {}

      unless fixtures.nil?
        if fixtures.instance_of?(Fixtures)
          @@loaded_fixtures[fixtures.table_name] = fixtures
        else
          fixtures.each { |f| @@loaded_fixtures[f.table_name] = f }
        end
      end

      table_names.each do |table_name|
        define_method(table_name) do |*fixtures|
          @@fixture_cache[table_name] ||= {}

          instances = fixtures.map do |fixture|
            if @@loaded_fixtures[table_name][fixture.to_s]
              @@fixture_cache[table_name][fixture] ||= @@loaded_fixtures[table_name][fixture.to_s].find
            else
              raise StandardError, "No fixture with name '#{fixture}' found for table '#{table_name}'"
            end
          end

          instances.size == 1 ? instances.first : instances
        end
      end
    end
  end
end
