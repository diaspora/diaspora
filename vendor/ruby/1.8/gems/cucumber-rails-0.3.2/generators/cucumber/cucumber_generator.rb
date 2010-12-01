require 'rbconfig'
require File.expand_path(File.join(File.dirname(__FILE__), '../../lib/generators/cucumber/install/install_base'))

# This generator bootstraps a Rails project for use with Cucumber
class CucumberGenerator < Rails::Generator::Base

  include Cucumber::Generators::InstallBase

  attr_accessor :driver
  attr_accessor :framework
  attr_reader :language, :template_dir

  def initialize(runtime_args, runtime_options = {})
    super
    @language = @args.empty? ? 'en' : @args.first
  end

  def manifest
    record do |m|
      check_upgrade_limitations
      create_templates(m, true)
      create_scripts(m, true)
      create_step_definitions(m, true)
      create_feature_support(m, true)
      create_tasks(m, true)
      create_database(m, true)
    end
  end

  def framework
    options[:framework] ||= detect_current_framework || detect_default_framework
  end

  def driver
    options[:driver] ||= detect_current_driver || detect_default_driver
  end

  def cucumber_rails_env
    'cucumber'
  end

  def self.gem_root
    File.expand_path('../../../', __FILE__)
  end

  def self.source_root
    File.join(gem_root, 'templates', 'install')
  end

  def source_root
    self.class.source_root
  end

  private

  def banner
    "Usage: #{$0} cucumber (language)"
  end

  def after_generate
    print_instructions
  end

  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on('--webrat', 'Setup cucumber for use with webrat') do
      options[:driver] = :webrat
    end

    opt.on('--capybara', 'Setup cucumber for use with capybara') do
      options[:driver] = :capybara
    end

    opt.on('--rspec', "Setup cucumber for use with RSpec") do
      options[:framework] = :rspec
    end

    opt.on('--testunit', "Setup cucumber for use with test/unit") do
      options[:framework] = :testunit
    end

    opt.on('--spork', 'Setup cucumber for use with Spork') do
      options[:spork] = true
    end
  end

end
