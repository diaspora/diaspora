require File.join(File.dirname(__FILE__), '..', 'app', 'models', 'app_config')

module EnviromentConfiguration
  def self.heroku?
    ENV['HEROKU']
  end

  def self.secret_token_initializer_is_not_present?
    !File.exists?( File.join(Rails.root, 'config', 'initializers', 'secret_token.rb'))
  end

  def self.prevent_fetching_community_spotlight?
    return true if heroku?
    !ActiveRecord::Base.connection.table_exists?('people') || Rails.env == 'test' || AppConfig[:community_spotlight].nil? || AppConfig[:community_spotlight].count
  end

  def self.cache_git_version?
    !self.heroku?
  end

  def self.ensure_secret_token!
    if heroku?
      puts 'heroku app detected; using session secret from config vars...'
      Rails.application.config.secret_token = ENV['SECRET_TOKEN'] 
    elsif secret_token_initializer_is_not_present?
      `rake generate:secret_token`
      require  File.join(Rails.root, 'config', 'initializers', 'secret_token.rb')
    else
      #do nothing
    end
  end

  def self.circumvent_ssl?
    ENV['NO_SSL'] || AppConfig[:circumvent_ssl_requirement].present?
  end

  def self.ca_cert_file_location
    if self.heroku?
      "/usr/lib/ssl/certs/ca-certificates.crt"
    else
      AppConfig[:ca_file]
    end
  end

  def self.using_new_relic?
    defined?(NewRelic) && AppConfig['NEW_RELIC_LICENSE_KEY'].present?
  end
end
