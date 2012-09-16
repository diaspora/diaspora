require Rails.root.join('lib', 'configuration')
require Rails.root.join('lib', 'configuration', 'methods')

config_dir = Rails.root.join("config")

if File.exists?(config_dir.join("application.yml"))
  puts "ATTENTION: There's a new configuration system, please remove your"
  puts "           application.yml and migrate your settings."
end

unless File.exists?(config_dir.join("diaspora.yml"))
  puts "FATAL: Configuration not found. Copy over diaspora.yml.example"
  puts "       to diaspora.yml and edit it to your needs."
  Process.exit(1)
end

AppConfig = Configuration::Settings.new do
  add_provider Configuration::Provider::Env.new
  add_provider Configuration::Provider::YAML.new config_dir.join("diaspora.yml"), namespace: Rails.env
  add_provider Configuration::Provider::YAML.new config_dir.join("diaspora.yml"), namespace: "configuration"
  add_provider Configuration::Provider::YAML.new config_dir.join("defaults.yml"), namespace: Rails.env
  add_provider Configuration::Provider::YAML.new config_dir.join("defaults.yml"), namespace: "defaults"
  extend Configuration::Methods
end
