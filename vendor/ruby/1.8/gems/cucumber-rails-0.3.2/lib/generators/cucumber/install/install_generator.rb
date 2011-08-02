require File.join(File.dirname(__FILE__), 'install_base')

module Cucumber
  class InstallGenerator < Rails::Generators::Base

    include Cucumber::Generators::InstallBase

    DEFAULT_SHEBANG = File.join(Config::CONFIG['bindir'], Config::CONFIG['ruby_install_name'])

    argument     :language,      :type => :string,  :banner => "LANG", :optional => true

    class_option :webrat,        :type => :boolean, :desc => "Use Webrat"
    class_option :capybara,      :type => :boolean, :desc => "Use Capybara"
    class_option :rspec,         :type => :boolean, :desc => "Use RSpec"
    class_option :testunit,      :type => :boolean, :desc => "Use Test::Unit"
    class_option :spork,         :type => :boolean, :desc => "Use Spork"
    class_option :skip_database, :type => :boolean, :desc => "Skip modification of database.yml", :aliases => '-D', :default => false

    attr_reader :framework, :driver

    def configure_defaults
      @language ||= 'en'
      @framework  = framework_from_options || detect_current_framework || detect_default_framework
      @driver     = driver_from_options    || detect_current_driver    || detect_default_driver
    end

    def generate
      check_upgrade_limitations
      create_templates
      create_scripts
      create_step_definitions
      create_feature_support
      create_tasks
      create_database unless options[:skip_database]
    end
  
    def self.gem_root
      File.expand_path("../../../../../", __FILE__)
    end
  
    def self.source_root
      File.join(gem_root, 'templates/install')
    end

    def cucumber_rails_env
      'test'
    end

    private
  
    def framework_from_options
      return :rspec if options[:rspec]
      return :testunit if options[:testunit]
      return nil
    end

    def driver_from_options
      return :webrat if options[:webrat]
      return :capybara if options[:capybara]
      return nil
    end
  
  end
end