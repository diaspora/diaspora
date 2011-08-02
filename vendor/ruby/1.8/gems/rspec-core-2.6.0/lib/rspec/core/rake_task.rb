#!/usr/bin/env ruby

require 'rspec/core'
require 'rspec/core/deprecation'
require 'rake'
require 'rake/tasklib'

module RSpec
  module Core
    class RakeTask < ::Rake::TaskLib

      # Name of task.
      #
      # default:
      #   :spec
      attr_accessor :name

      # Glob pattern to match files.
      #
      # default:
      #   'spec/**/*_spec.rb'
      attr_accessor :pattern

      # By default, if there is a Gemfile, the generated command will include
      # 'bundle exec'. Set this to true to ignore the presence of a Gemfile, and
      # not add 'bundle exec' to the command.
      #
      # default:
      #   false
      attr_accessor :skip_bundler

      # Name of Gemfile to use
      #
      # default:
      #   Gemfile
      attr_accessor :gemfile

      # Deprecated. Use ruby_opts="-w" instead.
      #
      # When true, requests that the specs be run with the warning flag set.
      # e.g. "ruby -w"
      #
      # default:
      #   false
      attr_reader :warning

      def warning=(true_or_false)
        RSpec.deprecate("RSpec::Core::RakeTask#warning=", 'ruby_opts="-w"')
        @warning = true_or_false
      end

      # Whether or not to fail Rake when an error occurs (typically when examples fail).
      #
      # default:
      #   true
      attr_accessor :fail_on_error

      # A message to print to stderr when there are failures.
      attr_accessor :failure_message

      # Use verbose output. If this is set to true, the task will print the
      # executed spec command to stdout.
      #
      # default:
      #   true
      attr_accessor :verbose

      # Use rcov for code coverage?
      #
      # default:
      #   false
      attr_accessor :rcov

      # Path to rcov.
      #
      # default:
      #   'rcov'
      attr_accessor :rcov_path

      # Command line options to pass to rcov.
      #
      # default:
      #   nil
      attr_accessor :rcov_opts

      # Command line options to pass to ruby.
      #
      # default:
      #   nil
      attr_accessor :ruby_opts

      # Path to rspec
      #
      # default:
      #   'rspec'
      attr_accessor :rspec_path

      # Command line options to pass to rspec.
      #
      # default:
      #   nil
      attr_accessor :rspec_opts

      # Deprecated. Use rspec_opts instead.
      #
      # Command line options to pass to rspec.
      #
      # default:
      #   nil
      def spec_opts=(opts)
        RSpec.deprecate('RSpec::Core::RakeTask#spec_opts=', 'rspec_opts=')
        @rspec_opts = opts
      end

      def initialize(*args)
        @name = args.shift || :spec
        @pattern, @rcov_path, @rcov_opts, @ruby_opts, @rspec_opts = nil, nil, nil, nil, nil
        @warning, @rcov, @skip_bundler = false, false, false
        @verbose, @fail_on_error = true, true
        @gemfile = 'Gemfile'

        yield self if block_given?

        @rcov_path  ||= 'rcov'
        @rspec_path ||= 'rspec'
        @pattern    ||= './spec/**/*_spec.rb'

        desc("Run RSpec code examples") unless ::Rake.application.last_comment

        task name do
          RakeFileUtils.send(:verbose, verbose) do
            if files_to_run.empty?
              puts "No examples matching #{pattern} could be found"
            else
              begin
                ruby(spec_command)
              rescue
                puts failure_message if failure_message
                raise("ruby #{spec_command} failed") if fail_on_error
              end
            end
          end
        end
      end

    private

      def files_to_run # :nodoc:
        if ENV['SPEC']
          FileList[ ENV['SPEC'] ]
        else
          FileList[ pattern ].map { |f| f.gsub(/"/, '\"').gsub(/'/, "\\\\'") }
        end
      end

      def spec_command
        @spec_command ||= begin
                            cmd_parts = [ruby_opts]
                            cmd_parts << "-w" if warning?
                            cmd_parts << "-S"
                            cmd_parts << "bundle exec" if gemfile? unless skip_bundler
                            cmd_parts << runner
                            if rcov
                              cmd_parts << ["-Ispec#{File::PATH_SEPARATOR}lib", rcov_opts]
                            else
                              cmd_parts << rspec_opts
                            end
                            cmd_parts << files_to_run
                            if rcov && rspec_opts
                              cmd_parts << ["--",  rspec_opts]
                            end
                            cmd_parts.flatten.compact.reject(&blank).join(" ")
                          end
      end

    private

      def runner
        rcov ? rcov_path : rspec_path
      end

      def warning?
        warning
      end

      def blank
        lambda {|s| s == ""}
      end

      def gemfile?
        File.exist?(gemfile)
      end

    end
  end
end
