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
  add_provider Configuration::Provider::Env
  add_provider Configuration::Provider::YAML,
               config_dir.join("diaspora.yml"),
               namespace: Rails.env, required: false
  add_provider Configuration::Provider::YAML,
               config_dir.join("diaspora.yml"),
               namespace: "configuration", required: false
  add_provider Configuration::Provider::YAML,
               config_dir.join("defaults.yml"),
               namespace: Rails.env
  add_provider Configuration::Provider::YAML,
               config_dir.join("defaults.yml"),
               namespace: "defaults"
  
  extend Configuration::Methods
  
  if environment.certificate_authorities.blank? || !File.exists?(environment.certificate_authorities)
    $stderr.puts "FATAL: Diaspora doesn't know where your certificate authorities are. Please ensure they are set to a valid path in diaspora.yml"
    Process.exit(1)
  end
end
