# frozen_string_literal: true

require "yaml"

module BundlerHelper
  def self.rails_env
    @rails_env ||= ENV["RAILS_ENV"] ||
      parse_value_from_toml_file("diaspora.toml", "rails_environment") ||
      parse_value_from_yaml_file("diaspora.yml", "configuration", "server", "rails_environment") ||
      parse_value_from_yaml_file("defaults.yml", "defaults", "server", "rails_environment")
  end

  def self.database
    @adapter ||= parse_value_from_yaml_file("database.yml", rails_env, "adapter")

    abort "No database adapter found, please fix your config/database.yml!" unless @adapter

    @adapter.sub("mysql2", "mysql")
  end

  private_class_method def self.parse_value_from_yaml_file(file, *keys)
    path = File.join(__dir__, file)
    YAML.load_file(path).dig(*keys) if File.file?(path)
  end

  private_class_method def self.parse_value_from_toml_file(file, key)
    path = File.join(__dir__, file)

    if File.file?(path)
      File.read(path)[/^\s*#{Regexp.escape(key)}\s*=\s*["']([^"']+)["']\s*$/, 1]
    elsif !File.file? File.join(__dir__, "diaspora.yml")
      warn "WARNING: Configuration file #{path} not found, ensure it's present" # rubocop:disable Rails/Output
    end
  end
end
