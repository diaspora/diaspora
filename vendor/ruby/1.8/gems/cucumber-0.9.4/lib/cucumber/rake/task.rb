require 'cucumber/platform'

module Cucumber
  module Rake
    # Defines a Rake task for running features.
    #
    # The simplest use of it goes something like:
    #
    #   Cucumber::Rake::Task.new
    #
    # This will define a task named <tt>cucumber</tt> described as 'Run Cucumber features'. 
    # It will use steps from 'features/**/*.rb' and features in 'features/**/*.feature'.
    #
    # To further configure the task, you can pass a block:
    #
    #   Cucumber::Rake::Task.new do |t|
    #     t.cucumber_opts = %w{--format progress}
    #   end
    #
    # This task can also be configured to be run with RCov:
    #
    #   Cucumber::Rake::Task.new do |t|
    #     t.rcov = true
    #   end
    # 
    # See the attributes for additional configuration possibilities.
    class Task
      class InProcessCucumberRunner #:nodoc:
        attr_reader :args
        
        def initialize(libs, cucumber_opts, feature_files)
          raise "libs must be an Array when running in-process" unless Array === libs
          libs.reverse.each{|lib| $LOAD_PATH.unshift(lib)}
          @args = (
            cucumber_opts + 
            feature_files
          ).flatten.compact
        end
        
        def run
          require 'cucumber/cli/main'
          failure = Cucumber::Cli::Main.execute(args)
          raise "Cucumber failed" if failure
        end
      end
      
      class ForkedCucumberRunner #:nodoc:
        attr_reader :args
        
        def initialize(libs, cucumber_bin, cucumber_opts, feature_files)
          @args = (
            ['-I'] + load_path(libs) + 
            quoted_binary(cucumber_bin) + 
            cucumber_opts + 
            feature_files
          ).flatten
        end

        def load_path(libs)
          ['"%s"' % libs.join(File::PATH_SEPARATOR)]
        end

        def quoted_binary(cucumber_bin)
          ['"%s"' % cucumber_bin]
        end

        def runner
          File.exist?("./Gemfile") && Gem.available?("bundler") ? ["bundle", "exec", RUBY] : [RUBY]
        end

        def run
          sh((runner + args).join(" "))
        end
      end

      class RCovCucumberRunner < ForkedCucumberRunner #:nodoc:
        def initialize(libs, cucumber_bin, cucumber_opts, feature_files, rcov_opts)
          @args = (
            ['-I'] + load_path(libs) + 
            ['-S', 'rcov'] + rcov_opts +
            quoted_binary(cucumber_bin) + 
            ['--'] + 
            cucumber_opts + 
            feature_files
          ).flatten
        end
      end

      LIB = File.expand_path(File.dirname(__FILE__) + '/../..') #:nodoc:

      # Directories to add to the Ruby $LOAD_PATH
      attr_accessor :libs

      # Name of the cucumber binary to use for running features. Defaults to Cucumber::BINARY
      attr_accessor :binary

      # Extra options to pass to the cucumber binary. Can be overridden by the CUCUMBER_OPTS environment variable.
      # It's recommended to pass an Array, but if it's a String it will be #split by ' '.
      attr_accessor :cucumber_opts
      def cucumber_opts=(opts) #:nodoc:
        @cucumber_opts = String === opts ? opts.split(' ') : opts
      end

      # Run cucumber with RCov? Defaults to false. If you set this to
      # true, +fork+ is implicit.
      attr_accessor :rcov

      # Extra options to pass to rcov.
      # It's recommended to pass an Array, but if it's a String it will be #split by ' '.
      attr_accessor :rcov_opts
      def rcov_opts=(opts) #:nodoc:
        @rcov_opts = String === opts ? opts.split(' ') : opts
      end

      # Whether or not to fork a new ruby interpreter. Defaults to true. You may gain
      # some startup speed if you set it to false, but this may also cause issues with
      # your load path and gems.
      attr_accessor :fork

      # Define what profile to be used.  When used with cucumber_opts it is simply appended 
      # to it. Will be ignored when CUCUMBER_OPTS is used.
      attr_accessor :profile

      # Define Cucumber Rake task
      def initialize(task_name = "cucumber", desc = "Run Cucumber features")
        @task_name, @desc = task_name, desc
        @fork = true
        @libs = ['lib']
        @rcov_opts = %w{--rails --exclude osx\/objc,gems\/}

        yield self if block_given?

        @binary = binary.nil? ? Cucumber::BINARY : File.expand_path(binary)
        @libs.insert(0, LIB) if binary == Cucumber::BINARY

        define_task
      end

      def define_task #:nodoc:
        desc @desc
        task @task_name do
          runner.run
        end
      end

      def runner(task_args = nil) #:nodoc:
        cucumber_opts = [(ENV['CUCUMBER_OPTS'] ? ENV['CUCUMBER_OPTS'].split(/\s+/) : nil) || cucumber_opts_with_profile]
        if(@rcov)
          RCovCucumberRunner.new(libs, binary, cucumber_opts, feature_files, rcov_opts)
        elsif(@fork)
          ForkedCucumberRunner.new(libs, binary, cucumber_opts, feature_files)
        else
          InProcessCucumberRunner.new(libs, cucumber_opts, feature_files)
        end
      end

      def cucumber_opts_with_profile #:nodoc:
        @profile ? [cucumber_opts, '--profile', @profile] : cucumber_opts
      end

      def feature_files #:nodoc:
        make_command_line_safe(FileList[ ENV['FEATURE'] || [] ])
      end

      def make_command_line_safe(list)
        list.map{|string| string.gsub(' ', '\ ')}
      end
    end
  end
end
