module RSpec
  module Core
    class CommandLineConfiguration
      attr_reader :command

      def initialize(cmd)
        @command = cmd
      end

      def run
        case @command
        when 'autotest' then Autotest.generate
        else raise ArgumentError, <<-MESSAGE

#{"*"*50}
"#{@command}" is not valid a valid argument to "rspec --configure".
Supported options are:

  rspec --configure autotest # generates .rspec file

#{"*"*50}
MESSAGE
        end
      end

      class Autotest
        class << self
          def generate
            create_dot_rspec_file
            remove_autotest_dir_if_present
          end

          def create_dot_rspec_file
            puts "Autotest loads RSpec's Autotest subclass when there is a .rspec file in the project's root directory."
            if File.exist?('./.rspec')
              puts ".rspec file already exists, so nothing was changed."
            else
              FileUtils.touch('./.rspec')
              puts ".rspec file did not exist, so it was created."
            end
          end

          def remove_autotest_dir_if_present
            if discover_file_exists?
              print "Delete obsolete autotest/discover.rb [y/n]? "
              exit if gets !~ /y/i
              FileUtils.rm_rf(discover_file_path)
            end
          end

          def discover_file_exists?
            File.exist?(discover_file_path)
          end

          def discover_file_path
            File.join('autotest', 'discover.rb')
          end
        end
      end
    end
  end
end
