require Rails.root.join('lib', 'configuration_methods')

config_dir = Rails.root.join("config")

if File.exists?(config_dir.join("application.yml"))
  $stderr.puts "ATTENTION: There's a new configuration system, please remove your"
  $stderr.puts "           application.yml and migrate your settings."
end


AppConfig ||= Configurate::Settings.create do
  add_provider Configurate::Provider::Dynamic
  add_provider Configurate::Provider::Env
  
  unless heroku? || Rails.env == "test" || File.exists?(config_dir.join("diaspora.yml"))
    $stderr.puts "FATAL: Configuration not found. Copy over diaspora.yml.example"
    $stderr.puts "       to diaspora.yml and edit it to your needs."
    Process.exit(1)
  end
  
  add_provider Configurate::Provider::YAML,
               config_dir.join("diaspora.yml"),
               namespace: Rails.env, required: false
  add_provider Configurate::Provider::YAML,
               config_dir.join("diaspora.yml"),
               namespace: "configuration", required: false
  add_provider Configurate::Provider::YAML,
               config_dir.join("defaults.yml"),
               namespace: Rails.env
  add_provider Configurate::Provider::YAML,
               config_dir.join("defaults.yml"),
               namespace: "defaults"
  
  extend Configuration::Methods
  
  if Rails.env == "production"  && (environment.certificate_authorities.blank? || !File.file?(environment.certificate_authorities.get))
    $stderr.puts "FATAL: Diaspora doesn't know where your certificate authorities are. Please ensure they are set to a valid path in diaspora.yml"
    Process.exit(1)
  end
end
