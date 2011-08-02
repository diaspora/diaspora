#!/usr/bin/env ruby

# Define a task library for performing code coverage analysis of unit tests
# using rcov.

require 'rake'
require 'rake/tasklib'

module Rcov

  # Create a task that runs a set of tests through rcov, generating code
  # coverage reports.
  #
  # Example:
  #
  #   require 'rcov/rcovtask'
  #
  #   Rcov::RcovTask.new do |t|
  #     t.libs << "test"
  #     t.test_files = FileList['test/test*.rb']
  #     t.verbose = true
  #   end
  #
  # If rake is invoked with a "TEST=filename" command line option,
  # then the list of test files will be overridden to include only the
  # filename specified on the command line.  This provides an easy way
  # to run just one test.
  #
  # If rake is invoked with a "RCOVOPTS=options" command line option,
  # then the given options are passed to rcov.
  #
  # If rake is invoked with a "RCOVPATH=path/to/rcov" command line option,
  # then the given rcov executable will be used; otherwise the one in your
  # PATH will be used.
  #
  # Examples:
  #
  #   rake rcov                           # run tests normally
  #   rake rcov TEST=just_one_file.rb     # run just one test file.
  #   rake rcov RCOVOPTS="-p"             # run in profile mode
  #   rake rcov RCOVOPTS="-T"             # generate text report
  #
  class RcovTask < Rake::TaskLib

    # Name of test task. (default is :rcov)
    attr_accessor :name

    # List of directories to added to $LOAD_PATH before running the
    # tests. (default is 'lib')
    attr_accessor :libs

    # True if verbose test output desired. (default is false)
    attr_accessor :verbose

    # Request that the tests be run with the warning flag set.
    # E.g. warning=true implies "ruby -w" used to run the tests.
    attr_accessor :warning

    # Glob pattern to match test files. (default is 'test/test*.rb')
    attr_accessor :pattern
    
    # Array of commandline options to pass to ruby when running the rcov loader.
    attr_accessor :ruby_opts

    # Array of commandline options to pass to rcov. An explicit
    # RCOVOPTS=opts on the command line will override this. (default
    # is <tt>["--text-report"]</tt>)
    attr_accessor :rcov_opts

    # Output directory for the XHTML report.
    attr_accessor :output_dir

    # Explicitly define the list of test files to be included in a
    # test.  +list+ is expected to be an array of file names (a
    # FileList is acceptable).  If both +pattern+ and +test_files+ are
    # used, then the list of test files is the union of the two.
    def test_files=(list)
      @test_files = list
    end

    # Create a testing task.
    def initialize(name=:rcov)
      @name = name
      @libs = ["lib"]
      @pattern = nil
      @test_files = nil
      @verbose = false
      @warning = false
      @rcov_opts = ["--text-report"]
      @ruby_opts = []
      @ruby_opts << "--debug" if RUBY_PLATFORM == 'java'
      @output_dir = "coverage"
      yield self if block_given?
      @pattern = 'test/test*.rb' if @pattern.nil? && @test_files.nil?
      define
    end

    # Create the tasks defined by this task lib.
    def define
      lib_path = @libs.join(File::PATH_SEPARATOR)
      actual_name = Hash === name ? name.keys.first : name
      unless Rake.application.last_comment
        desc "Analyze code coverage with tests" + 
          (@name==:rcov ? "" : " for #{actual_name}")
      end
      task @name do
        run_code = ''
        RakeFileUtils.verbose(@verbose) do
          run_code =
          case rcov_path
          when nil, ''
            "-S rcov"
          else %!"#{rcov_path}"!
          end
          ruby_opts = @ruby_opts.clone
          ruby_opts.push( "-I#{lib_path}" )
          ruby_opts.push run_code
          ruby_opts.push( "-w" ) if @warning
          ruby ruby_opts.join(" ") + " " + option_list +
          %[ -o "#{@output_dir}" ] +
          file_list.collect { |fn| %["#{fn}"] }.join(' ')
        end
      end

      desc "Remove rcov products for #{actual_name}"
      task paste("clobber_", actual_name) do
        rm_r @output_dir rescue nil
      end

      clobber_task = paste("clobber_", actual_name)
      task :clobber => [clobber_task]

      task actual_name => clobber_task
      self
    end

    def rcov_path # :nodoc:
      ENV['RCOVPATH']
    end

    def option_list # :nodoc:
      ENV['RCOVOPTS'] || @rcov_opts.join(" ") || ""
    end

    def file_list # :nodoc:
      if ENV['TEST']
        FileList[ ENV['TEST'] ]
      else
        result = []
        result += @test_files.to_a if @test_files
        result += FileList[ @pattern ].to_a if @pattern
        FileList[result]
      end
    end
  end
end
