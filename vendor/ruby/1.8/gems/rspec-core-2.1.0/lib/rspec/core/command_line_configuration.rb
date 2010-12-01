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

  rspec --configure autotest # generates configuration to run autotest with rspec

#{"*"*50}
MESSAGE
        end
      end

      class Autotest
        class << self
          def generate
            create_autotest_directory
            create_discover_file
            puts "autotest/discover.rb has been added"
          end

          def create_autotest_directory
            Dir.mkdir('autotest') unless File.exist?('autotest')
          end

          def create_discover_file
            optionally_remove_discover_file if discover_file_exists?
            File.open(discover_file_path, 'w') do |file|
              file << 'Autotest.add_discovery { "rspec2" }'
            end
          end

          def optionally_remove_discover_file
            print "Discover file already exists, overwrite [y/N]? "
            exit if gets !~ /y/i
            FileUtils.rm_rf(discover_file_path)
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
