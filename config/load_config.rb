require 'configurate'

rails_root = Pathname.new(__FILE__).dirname.join('..').expand_path
rails_env = ENV['RACK_ENV']
rails_env ||= ENV['RAILS_ENV']
rails_env ||= 'development'

require rails_root.join('lib', 'configuration_methods')

config_dir = rails_root.join("config")

if File.exists?(config_dir.join("application.yml"))
  $stderr.puts "ATTENTION: There's a new configuration system, please remove your"
  $stderr.puts "           application.yml and migrate your settings."
end


AppConfig ||= Configurate::Settings.create do
  add_provider Configurate::Provider::Dynamic
  add_provider Configurate::Provider::Env
  
  unless heroku? || rails_env == "test" || File.exists?(config_dir.join("diaspora.yml"))
    $stderr.puts "FATAL: Configuration not found. Copy over diaspora.yml.example"
    $stderr.puts "       to diaspora.yml and edit it to your needs."
    Process.exit(1)
  end
  
  add_provider Configurate::Provider::YAML,
               config_dir.join("diaspora.yml"),
               namespace: rails_env, required: false
  add_provider Configurate::Provider::YAML,
               config_dir.join("diaspora.yml"),
               namespace: "configuration", required: false
  add_provider Configurate::Provider::YAML,
               config_dir.join("defaults.yml"),
               namespace: rails_env
  add_provider Configurate::Provider::YAML,
               config_dir.join("defaults.yml"),
               namespace: "defaults"
  
  extend Configuration::Methods
  
if rails_env == "production"  &&
    (environment.certificate_authorities.nil? ||
     environment.certificate_authorities.empty? ||
     !File.file?(environment.certificate_authorities.get))
    $stderr.puts "FATAL: Diaspora doesn't know where your certificate authorities are. Please ensure they are set to a valid path in diaspora.yml"
    Process.exit(1)
  end
end
