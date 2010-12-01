require 'rubygems'

require 'tempfile'
require 'rspec/expectations'
require 'fileutils'
require 'forwardable'
require 'cucumber/formatter/unicode'
# This is to force miniunit to be loaded on 1.9.2, and verify that we can still run with --profile. See:
# * disable_mini_test_autorun.rb and 
# * http://groups.google.com/group/cukes/browse_thread/thread/5682d41436e235d7
# * https://rspec.lighthouseapp.com/projects/16211/tickets/677-cucumber-093-prevents-testunit-from-running
require 'test/unit'

class CucumberWorld
  extend Forwardable
  def_delegators CucumberWorld, :fixtures_dir, :self_test_dir, :working_dir, :cucumber_lib_dir

  def self.fixtures_dir(subdir=nil)
    @fixtures_dir ||= File.expand_path(File.join(File.dirname(__FILE__), '../../fixtures'))
    subdir ? File.join(@fixtures_dir, subdir) : @fixtures_dir
  end

  def self.self_test_dir
    @self_test_dir ||= fixtures_dir('self_test')
  end

  def self.working_dir
    @working_dir ||= fixtures_dir('self_test/tmp')
  end

  def cucumber_lib_dir
    @cucumber_lib_dir ||= File.expand_path(File.join(File.dirname(__FILE__), '../../lib'))
  end
  
  # Don't use Cucumber::BINARY (which is the binary used to start the "outer" cucumber)
  # Instead we force the use of this codebase's cucumber bin script.
  # This allows us to run cucumber's cukes with an older, stable cucumber.
  def cucumber_bin
    File.expand_path(File.dirname(__FILE__) + '/../../bin/cucumber')
  end

  def initialize
    @current_dir = self_test_dir
  end

  private
  attr_reader :last_exit_status, :last_stderr

  # The last standard out, with the duration line taken out (unpredictable)
  def last_stdout
    strip_1_9_paths(strip_duration(@last_stdout))
  end

  def combined_output
    last_stdout + "\n" + last_stderr
  end

  def strip_duration(s)
    s.gsub(/^\d+m\d+\.\d+s\n/m, "")
  end

  def strip_1_9_paths(s)
    s.gsub(/#{Dir.pwd}\/fixtures\/self_test\/tmp/m, ".").gsub(/#{Dir.pwd}\/fixtures\/self_test/m, ".")
  end

  def replace_duration(s, replacement)
    s.gsub(/\d+m\d+\.\d+s/m, replacement)
  end

  def replace_junit_duration(s, replacement)
    s.gsub(/\d+\.\d\d+/m, replacement)
  end

  def strip_ruby186_extra_trace(s)  
    s.gsub(/^.*\.\/features\/step_definitions(.*)\n/, "")
  end

  def create_file(file_name, file_content)
    file_content.gsub!("CUCUMBER_LIB", "'#{cucumber_lib_dir}'") # Some files, such as Rakefiles need to use the lib dir
    in_current_dir do
      FileUtils.mkdir_p(File.dirname(file_name)) unless File.directory?(File.dirname(file_name))
      File.open(file_name, 'w') { |f| f << file_content }
    end
  end

  def set_env_var(variable, value)
    @original_env_vars ||= {}
    @original_env_vars[variable] = ENV[variable] 
    ENV[variable]  = value
  end

  def background_jobs
    @background_jobs ||= []
  end

  def in_current_dir(&block)
    Dir.chdir(@current_dir, &block)
  end

  def run(command)
    stderr_file = Tempfile.new('cucumber')
    stderr_file.close
    in_current_dir do
      mode = Cucumber::RUBY_1_9 ? {:external_encoding=>"UTF-8"} : 'r'
      IO.popen("#{command} 2> #{stderr_file.path}", mode) do |io|
        @last_stdout = io.read
      end

      @last_exit_status = $?.exitstatus
    end
    @last_stderr = IO.read(stderr_file.path)
  end

  def run_spork_in_background(port = nil)
    require 'spork'

    pid = fork
    in_current_dir do
      if pid
        background_jobs << pid
      else
        # STDOUT.close
        # STDERR.close
        port_arg = port ? "-p #{port}" : ''
        cmd = "#{Cucumber::RUBY_BINARY} -I #{Cucumber::LIBDIR} #{Spork::BINARY} cuc #{port_arg}"
        exec cmd
      end
    end
    sleep 1.0
  end

  def terminate_background_jobs
    background_jobs.each do |pid|
      Process.kill(Signal.list['TERM'], pid)
    end
  end

  def restore_original_env_vars
    @original_env_vars.each { |variable, value| ENV[variable] = value } if @original_env_vars
  end

end

World do
  CucumberWorld.new
end

Before do
  FileUtils.rm_rf CucumberWorld.working_dir
  FileUtils.mkdir CucumberWorld.working_dir
end

After do
  FileUtils.rm_rf CucumberWorld.working_dir unless ENV['KEEP_FILES']
  terminate_background_jobs
  restore_original_env_vars
end
