if AppConfig.heroku?
  Rails.application.config.secret_token = AppConfig.secret_token
elsif !Rails.root.join('config', 'initializers', 'secret_token.rb').exist?
  `bundle exec rake generate:secret_token`
  require  Rails.root.join('config', 'initializers', 'secret_token.rb')
end 
