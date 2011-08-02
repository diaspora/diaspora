require 'autotest'
require 'tempfile'
require 'cucumber'
require 'cucumber/cli/profile_loader'

module Autotest::CucumberMixin
  def self.included(receiver)
    receiver::ALL_HOOKS << [:run_features, :ran_features]
  end
  
  attr_accessor :features_to_run
  
  def initialize
    super
    reset_features
  end
  
  def run
    hook :initialize
    reset
    reset_features
    add_sigint_handler

    self.last_mtime = Time.now if $f

    loop do # ^c handler
      begin
        get_to_green
        if self.tainted then
          rerun_all_tests
          rerun_all_features if all_good
        else
          hook :all_good
        end
        wait_for_changes
        # Once tests and features are green, reset features every
        # time a file is changed to see if anything breaks.
        reset_features
      rescue Interrupt
        break if self.wants_to_quit
        reset
        reset_features
      end
    end
    hook :quit
  end
  
  def all_features_good
    features_to_run == ""
  end
  
  def get_to_green
    begin
      super
      run_features
      wait_for_changes unless all_features_good
    end until all_features_good
  end
  
  def rerun_all_features
    reset_features
    run_features
  end
  
  def reset_features
    self.features_to_run = :all
  end
    
  def run_features
    hook :run_features
    Tempfile.open('autotest-cucumber') do |dirty_features_file|
      cmd = self.make_cucumber_cmd(self.features_to_run, dirty_features_file.path)
      return if cmd.empty?
      puts cmd unless $q
      old_sync = $stdout.sync
      $stdout.sync = true
      self.results = []
      line = []
      begin
        open("| #{cmd}", "r") do |f|
          until f.eof? do
            c = f.getc or break
            if RUBY_VERSION >= "1.9" then
              print c
            else
              putc c
            end
            line << c
            if c == ?\n then
              self.results << if RUBY_VERSION >= "1.9" then
                                line.join
                              else
                                line.pack "c*"
                              end
              line.clear
            end
          end
        end
      ensure
        $stdout.sync = old_sync
      end
      self.features_to_run = dirty_features_file.read.strip
      self.tainted = true unless self.features_to_run == ''
    end
    hook :ran_features
  end
  
  def make_cucumber_cmd(features_to_run, dirty_features_filename)
    return '' if features_to_run == ''
    
    profile_loader = Cucumber::Cli::ProfileLoader.new
    
    profile ||= "autotest-all" if profile_loader.has_profile?("autotest-all") && features_to_run == :all
    profile ||= "autotest"     if profile_loader.has_profile?("autotest")
    profile ||= nil
    
    if profile
      args = ["--profile", profile]
    else
      args = %w{--format} << (features_to_run == :all ? "progress" : "pretty")
    end
    # No --color option as some IDEs (Netbeans) don't output them very well ([31m1 failed step[0m)
    args += %w{--format rerun --out} << dirty_features_filename
    args << (features_to_run == :all ? "" : features_to_run)
    
    # Unless I do this, all the steps turn up undefined during the rerun...
    unless features_to_run == :all
      args << 'features/step_definitions' << 'features/support'
    end
    
    args = args.join(' ')

    return "#{Cucumber::RUBY_BINARY} #{Cucumber::BINARY} #{args}"
  end
end
