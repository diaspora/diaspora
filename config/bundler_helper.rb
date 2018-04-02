# frozen_string_literal: true

require "yaml"

module BundlerHelper
  def self.rails_env
    @rails_env ||= ENV["RAILS_ENV"] ||
      parse_value_from_file("diaspora.yml", "configuration", "server", "rails_environment") ||
      parse_value_from_file("defaults.yml", "defaults", "server", "rails_environment")
  end

  def self.database
    @adapter ||= parse_value_from_file("database.yml", rails_env, "adapter")

    raise "No database adapter found, please fix your config/database.yml!" unless @adapter

    @adapter.sub("mysql2", "mysql")
  end

  def self.enable_pam?
    return @enable_pam unless @enable_pam.nil?
    @enable_pam = parse_value_from_file("diaspora.yml", rails_env, "pam", "enable")
    @enable_pam = parse_value_from_file("diaspora.yml", "configuration", "pam", "enable") if @enable_pam.nil?
    @enable_pam = parse_value_from_file("defaults.yml", rails_env, "pam", "enable") if @enable_pam.nil?
    @enable_pam = parse_value_from_file("defaults.yml", "defaults", "pam", "enable") if @enable_pam.nil?
    @enable_pam
  end

  private_class_method def self.parse_value_from_file(file, *keys)
    path = File.join(__dir__, file)
    return YAML.load_file(path).dig(*keys) if File.file?(path)

    puts "Configuration file #{path} not found, ensure it's present" # rubocop:disable Rails/Output
  end
end
