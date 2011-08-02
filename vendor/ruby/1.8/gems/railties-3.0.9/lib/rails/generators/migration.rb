module Rails
  module Generators
    # Holds common methods for migrations. It assumes that migrations has the
    # [0-9]*_name format and can be used by another frameworks (like Sequel)
    # just by implementing the next migration version method.
    #
    module Migration
      attr_reader :migration_number, :migration_file_name, :migration_class_name

      def self.included(base) #:nodoc:
        base.extend ClassMethods
      end

      module ClassMethods
        def migration_lookup_at(dirname) #:nodoc:
          Dir.glob("#{dirname}/[0-9]*_*.rb")
        end

        def migration_exists?(dirname, file_name) #:nodoc:
          migration_lookup_at(dirname).grep(/\d+_#{file_name}.rb$/).first
        end

        def current_migration_number(dirname) #:nodoc:
          migration_lookup_at(dirname).collect do |file|
            File.basename(file).split("_").first.to_i
          end.max.to_i
        end

        def next_migration_number(dirname) #:nodoc:
          raise NotImplementedError
        end
      end

      # Creates a migration template at the given destination. The difference
      # to the default template method is that the migration version is appended
      # to the destination file name.
      #
      # The migration version, migration file name, migration class name are
      # available as instance variables in the template to be rendered.
      #
      # ==== Examples
      #
      #   migration_template "migration.rb", "db/migrate/add_foo_to_bar.rb"
      #
      def migration_template(source, destination=nil, config={})
        destination = File.expand_path(destination || source, self.destination_root)

        migration_dir = File.dirname(destination)
        @migration_number     = self.class.next_migration_number(migration_dir)
        @migration_file_name  = File.basename(destination).sub(/\.rb$/, '')
        @migration_class_name = @migration_file_name.camelize

        destination = self.class.migration_exists?(migration_dir, @migration_file_name)

        if behavior == :invoke
          raise Error, "Another migration is already named #{@migration_file_name}: #{destination}" if destination
          destination = File.join(migration_dir, "#{@migration_number}_#{@migration_file_name}.rb")
        end

        template(source, destination, config)
      end
    end
  end
end
