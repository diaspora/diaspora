#!/usr/bin/env ruby

begin
  require 'rubygems'
rescue LoadError => ex
end
require 'test/unit'
require 'fileutils'
require 'session'
require 'test/in_environment'
require 'test/rake_test_setup'

# Version 2.1.9 of session has a bug where the @debug instance
# variable is not initialized, causing warning messages.  This snippet
# of code fixes that problem.
module Session
  class AbstractSession
    alias old_initialize initialize
    def initialize(*args)
      @debug = nil
      old_initialize(*args)
    end
  end
end

class FunctionalTest < Test::Unit::TestCase
  include InEnvironment
  include TestMethods

  RUBY_COMMAND = 'ruby'

  def setup
    @rake_path = File.expand_path("bin/rake")
    lib_path = File.expand_path("lib")
    @ruby_options = "-I#{lib_path} -I."
    @verbose = ! ENV['VERBOSE'].nil?
    if @verbose
      puts
      puts
      puts "--------------------------------------------------------------------"
      puts name
      puts "--------------------------------------------------------------------"
    end
  end

  def test_rake_default
    Dir.chdir("test/data/default") do rake end
    assert_match(/^DEFAULT$/, @out)
    assert_status
  end

  def test_rake_error_on_bad_task
    Dir.chdir("test/data/default") do rake "xyz" end
    assert_match(/rake aborted/, @err)
    assert_status(1)
  end

  def test_env_availabe_at_top_scope
    Dir.chdir("test/data/default") do rake "TESTTOPSCOPE=1" end
    assert_match(/^TOPSCOPE$/, @out)
    assert_status
  end

  def test_env_availabe_at_task_scope
    Dir.chdir("test/data/default") do rake "TESTTASKSCOPE=1 task_scope" end
    assert_match(/^TASKSCOPE$/, @out)
    assert_status
  end

  def test_multi_desc
    in_environment(
      'RAKE_COLUMNS' => "80",
      "PWD" => "test/data/multidesc"
      ) do
      rake "-T"
    end
    assert_match %r{^rake a *# A / A2 *$}, @out
    assert_match %r{^rake b *# B *$}, @out
    assert_no_match %r{^rake c}, @out
    assert_match %r{^rake d *# x{65}\.\.\.$}, @out
  end
  
  def test_long_description
    in_environment("PWD" => "test/data/multidesc") do
      rake "--describe"
    end
    assert_match %r{^rake a\n *A / A2 *$}m, @out
    assert_match %r{^rake b\n *B *$}m, @out
    assert_match %r{^rake d\n *x{80}}m, @out
    assert_no_match %r{^rake c\n}m, @out
  end

  def test_rbext
    in_environment("PWD" => "test/data/rbext") do
      rake "-N"
    end
    assert_match %r{^OK$}, @out
  end

  def test_system
    in_environment('RAKE_SYSTEM' => 'test/data/sys') do
      rake '-g', "sys1"
    end
    assert_match %r{^SYS1}, @out
  end

  def test_system_excludes_rakelib_files_too
    in_environment('RAKE_SYSTEM' => 'test/data/sys') do
      rake '-g', "sys1", '-T', 'extra'
    end
    assert_no_match %r{extra:extra}, @out
  end

  def test_by_default_rakelib_files_are_include
    in_environment('RAKE_SYSTEM' => 'test/data/sys') do
      rake '-T', 'extra'
    end
    assert_match %r{extra:extra}, @out
  end

  def test_implicit_system
    in_environment('RAKE_SYSTEM' => File.expand_path('test/data/sys'), "PWD" => "/") do
      rake "sys1", "--trace"
    end
    assert_match %r{^SYS1}, @out
  end

  def test_no_system
    in_environment('RAKE_SYSTEM' => 'test/data/sys') do
      rake '-G', "sys1"
    end
    assert_match %r{^Don't know how to build task}, @err # emacs wart: '
  end

  def test_nosearch_with_rakefile_uses_local_rakefile
    in_environment("PWD" => "test/data/default") do
      rake "--nosearch"
    end
    assert_match %r{^DEFAULT}, @out
  end

  def test_nosearch_without_rakefile_finds_system
    in_environment(
      "PWD" => "test/data/nosearch",
      "RAKE_SYSTEM" => File.expand_path("test/data/sys")
      ) do
      rake "--nosearch", "sys1"
    end
    assert_match %r{^SYS1}, @out
  end

  def test_nosearch_without_rakefile_and_no_system_fails
    in_environment("PWD" => "test/data/nosearch", "RAKE_SYSTEM" => "not_exist") do
      rake "--nosearch"
    end
    assert_match %r{^No Rakefile found}, @err
  end

  def test_dry_run
    in_environment("PWD" => "test/data/default") do rake "-n", "other" end
    assert_match %r{Execute \(dry run\) default}, @out
    assert_match %r{Execute \(dry run\) other}, @out
    assert_no_match %r{DEFAULT}, @out
    assert_no_match %r{OTHER}, @out
  end

  # Test for the trace/dry_run bug found by Brian Chandler
  def test_dry_run_bug
    in_environment("PWD" => "test/data/dryrun") do
      rake
    end
    FileUtils.rm_f "test/data/dryrun/temp_one"
    in_environment("PWD" => "test/data/dryrun") do
      rake "--dry-run"
    end
    assert_no_match(/No such file/, @out)
    assert_status
  end

  # Test for the trace/dry_run bug found by Brian Chandler
  def test_trace_bug
    in_environment("PWD" => "test/data/dryrun") do
      rake
    end
    FileUtils.rm_f "test/data/dryrun/temp_one"
    in_environment("PWD" => "test/data/dryrun") do
      rake "--trace"
    end
    assert_no_match(/No such file/, @out)
    assert_status
  end

  def test_imports
    open("test/data/imports/static_deps", "w") do |f|
      f.puts 'puts "STATIC"'
    end
    FileUtils.rm_f "test/data/imports/dynamic_deps"
    in_environment("PWD" => "test/data/imports") do
      rake
    end
    assert File.exist?("test/data/imports/dynamic_deps"),
      "'dynamic_deps' file should exist"
    assert_match(/^FIRST$\s+^DYNAMIC$\s+^STATIC$\s+^OTHER$/, @out)
    assert_status
    FileUtils.rm_f "test/data/imports/dynamic_deps"
    FileUtils.rm_f "test/data/imports/static_deps"
  end

  def test_rules_chaining_to_file_task
    remove_chaining_files
    in_environment("PWD" => "test/data/chains") do
      rake
    end
    assert File.exist?("test/data/chains/play.app"),
      "'play.app' file should exist"
    assert_status
    remove_chaining_files
  end

  def test_file_creation_task
    in_environment("PWD" => "test/data/file_creation_task") do
      rake "prep"
      rake "run"
      rake "run"
    end
    assert(@err !~ /^cp src/, "Should not recopy data")
  end

  def test_dash_f_with_no_arg_foils_rakefile_lookup
    rake "-I test/data/rakelib -rtest1 -f"
    assert_match(/^TEST1$/, @out)
  end

  def test_dot_rake_files_can_be_loaded_with_dash_r
    rake "-I test/data/rakelib -rtest2 -f"
    assert_match(/^TEST2$/, @out)
  end

  def test_can_invoke_task_in_toplevel_namespace
    in_environment("PWD" => "test/data/namespace") do
      rake "copy"
    end
    assert_match(/^COPY$/, @out)
  end

  def test_can_invoke_task_in_nested_namespace
    in_environment("PWD" => "test/data/namespace") do
      rake "nest:copy"
      assert_match(/^NEST COPY$/, @out)
    end
  end

  def test_tasks_can_reference_task_in_same_namespace
    in_environment("PWD" => "test/data/namespace") do
      rake "nest:xx"
      assert_match(/^NEST COPY$/m, @out)
    end
  end

  def test_tasks_can_reference_task_in_other_namespaces
    in_environment("PWD" => "test/data/namespace") do
      rake "b:run"
      assert_match(/^IN A\nIN B$/m, @out)
    end
  end

  def test_anonymous_tasks_can_be_invoked_indirectly
    in_environment("PWD" => "test/data/namespace") do
      rake "anon"
      assert_match(/^ANON COPY$/m, @out)
    end
  end

  def test_rake_namespace_refers_to_toplevel
    in_environment("PWD" => "test/data/namespace") do
      rake "very:nested:run"
      assert_match(/^COPY$/m, @out)
    end
  end

  def test_file_task_are_not_scoped_by_namespaces
    in_environment("PWD" => "test/data/namespace") do
      rake "xyz.rb"
      assert_match(/^XYZ1\nXYZ2$/m, @out)
    end
  end
  
  def test_rake_returns_status_error_values
    in_environment("PWD" => "test/data/statusreturn") do
      rake "exit5"
      assert_status(5)
    end
  end

  def test_rake_returns_no_status_error_on_normal_exit
    in_environment("PWD" => "test/data/statusreturn") do
      rake "normal"
      assert_status(0)
    end
  end

  private

  def remove_chaining_files
    %w(play.scpt play.app base).each do |fn|
      FileUtils.rm_f File.join("test/data/chains", fn)
    end
  end

  class << self
    def format_command
      @format_command ||= lambda { |ruby_options, rake_path, options|
        "ruby #{ruby_options} #{rake_path} #{options}"
      }
    end
    
    def format_command=(fmt_command)
      @format_command = fmt_command
    end
  end
  
  def rake(*option_list)
    options = option_list.join(' ')
    shell = Session::Shell.new
    command = self.class.format_command[@ruby_options, @rake_path, options]
    puts "COMMAND: [#{command}]" if @verbose
    @out, @err = shell.execute command
    @status = shell.exit_status
    puts "STATUS:  [#{@status}]" if @verbose
    puts "OUTPUT:  [#{@out}]" if @verbose
    puts "ERROR:   [#{@err}]" if @verbose
    puts "PWD:     [#{Dir.pwd}]" if @verbose
    shell.close
  end

  def assert_status(expected_status=0)
    assert_equal expected_status, @status
  end
end
