# frozen_string_literal: true

require "pathname"
require "bundler/setup"
require "configurate"
require "configurate/provider/toml"

rails_env = ENV["RAILS_ENV"] || ENV["RACK_ENV"] || "development"

module Rails
  def self.root
    @__root ||= Pathname.new File.expand_path("../../", __FILE__)
  end
end

require Rails.root.join "lib", "configuration_methods"

config_dir = Rails.root.join("config").to_s

AppConfig ||= Configurate::Settings.create do
  add_provider Configurate::Provider::Dynamic
  add_provider Configurate::Provider::Env

  unless heroku? ||
    rails_env == "test" ||
    File.exist?(File.join(config_dir, "diaspora.toml")) ||
    File.exist?(File.join(config_dir, "diaspora.yml"))
    warn "FATAL: Configuration not found. Copy over diaspora.toml.example"
    warn "       to diaspora.toml and edit it to your needs."
    exit!
  end

  if File.exist?(File.join(config_dir, "diaspora.toml"))
    if File.exist?(File.join(config_dir, "diaspora.yml"))
      warn "WARNING: diaspora.toml found, ignoring diaspora.yml. Move or delete diaspora.yml to remove this warning."
    end

    add_provider Configurate::Provider::TOML,
                 File.join(config_dir, "diaspora.toml"),
                 namespace: rails_env, required: false
    add_provider Configurate::Provider::TOML,
                 File.join(config_dir, "diaspora.toml"),
                 namespace: "configuration", required: false
  else
    warn "WARNING: diaspora.yml is deprecated and will no longer be read in diaspora 1.0."
    warn "         Please copy over diaspora.toml.example to diaspora.toml and migrate your settings from diaspora.yml."

    add_provider Configurate::Provider::YAML,
                 File.join(config_dir, "diaspora.yml"),
                 namespace: rails_env, required: false
    add_provider Configurate::Provider::YAML,
                 File.join(config_dir, "diaspora.yml"),
                 namespace: "configuration", required: false
  end

  add_provider Configurate::Provider::YAML,
               File.join(config_dir, "defaults.yml"),
               namespace: rails_env
  add_provider Configurate::Provider::YAML,
               File.join(config_dir, "defaults.yml"),
               namespace: "defaults", raise_on_missing: true

  extend Configuration::Methods

  if rails_env == "production"  &&
     (environment.certificate_authorities.nil? ||
     environment.certificate_authorities.empty? ||
     !File.file?(environment.certificate_authorities.get))
    warn "FATAL: Diaspora doesn't know where your certificate authorities are." \
         " Please ensure they are set to a valid path in diaspora.yml"
    exit!
  end
end
